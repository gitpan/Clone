#include <assert.h>

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static SV *hv_clone (SV *, int);
static SV *av_clone (SV *, int);
static SV *sv_clone (SV *, int);
static SV *rv_clone (SV *, int);

static HV *hseen;

#if(0)
#define TRACEME(a) printf("%s:%d: ",__FUNCTION__, __LINE__) && printf a;
#else
#define TRACEME(a)
#endif

static SV *
hv_clone (SV * ref, int depth)
{
  HV *clone = newHV ();
  HV *self = (HV *) ref;
  HE *next = NULL;
  I32 retlen = 0;
  char *key;
  SV *val;
  int recur = depth ? depth - 1 : 0;

  assert(SvTYPE(ref) == SVt_PVHV);

  TRACEME(("ref = 0x%x\n", ref));

  hv_iterinit (self);
  while (next = hv_iternext (self))
    {
      key = hv_iterkey (next, &retlen);
      val = hv_iterval (self, next);
      val = sv_clone (val, recur);
      hv_store (clone, key, retlen, SvREFCNT_inc(val), 0);
    }

  TRACEME(("clone = 0x%x\n", clone));
  return (SV *) clone;
}

static SV *
av_clone (SV * ref, int depth)
{
  AV *clone = newAV ();
  AV *self = (AV *) ref;
  SV **svp;
  SV *val = NULL;
  I32 arrlen = 0;
  int i = 0;
  int recur = depth ? depth - 1 : 0;

  assert(SvTYPE(ref) == SVt_PVAV);

  TRACEME(("ref = 0x%x\n", ref));

  arrlen = av_len (self);
  av_extend (clone, arrlen);

  for (i = 0; i <= arrlen; i++)
    {
      svp = av_fetch (self, i, 0);
      if (svp)
	{
	  val = *svp;
          val = sv_clone (val, recur);
	  av_store (clone, i, SvREFCNT_inc(val));
	}
    }

  TRACEME(("clone = 0x%x\n", clone));
  return (SV *) clone;
}

static SV *
rv_clone (SV * ref, int depth)
{
  SV *clone = NULL;
  SV *rv = NULL;

  assert(SvROK(ref));

  TRACEME(("ref = 0x%x\n", ref));

  if (!SvROK (ref))
    return NULL;

  if (sv_isobject (ref))
    {
      clone = newRV_noinc(sv_clone (SvRV(ref), depth));
      sv_2mortal (sv_bless (clone, SvSTASH (SvRV (ref))));
    }
  else
    clone = newRV_inc(sv_clone (SvRV(ref), depth));
    
  TRACEME(("clone = 0x%x\n", clone));
  return clone;
}

static SV *
sv_clone (SV * ref, int depth)
{
  SV *clone = ref;
  MAGIC *mg = NULL;
  SV **svh = NULL;
  int mg_type = 0;

  TRACEME(("ref = 0x%x\n", ref));

  if (depth == 0)
    return SvREFCNT_inc(ref);

  svh = hv_fetch(hseen, (char *) &ref, sizeof(ref), FALSE);

  if(svh)
    {
      TRACEME(("fetch ref (0x%x)\n", ref));
      return SvREFCNT_inc(*svh);
    }

  TRACEME(("switch: (0x%x)\n", ref));
  switch (SvTYPE (ref))
    {
      case SVt_NULL:	/* 0 */
        TRACEME(("sv_null"));
        clone = newSVsv(&PL_sv_undef);
        break;
      case SVt_IV:		/* 1 */
        TRACEME(("int scalar"));
      case SVt_NV:		/* 2 */
        TRACEME(("double scalar"));
        mg_type = 'q';
        clone = newSVsv (ref);
        break;
      case SVt_RV:		/* 3 */
        TRACEME(("ref scalar"));
        clone = rv_clone(ref, depth);
        break;
      case SVt_PV:		/* 4 */
        TRACEME(("string scalar"));
        mg_type = 'q';
        clone = newSVsv (ref);
        break;
      case SVt_PVIV:		/* 5 */
        TRACEME (("PVIV double-type\n"));
      case SVt_PVNV:		/* 6 */
        TRACEME (("PVNV double-type\n"));
        clone = newSVsv (ref);
        if (SvROK (ref))
        {
	          TRACEME (("RV double-type\n"));
	          sv_setsv (clone, rv_clone (ref, depth));
	          if (SvNOKp (ref))
	            SvNOK_on (clone);
	          else
	            SvIOK_on (clone);
        }
        TRACEME (("clone = 0x%x\n", clone));
        break;
      case SVt_PVMG:	/* 7 */
        TRACEME(("magic scalar"));
        mg_type = 'q';
        clone = newSVsv (ref);
        break;
      case SVt_PVAV:	/* 10 */
        mg_type = 'P';
        clone = av_clone (ref, depth);
        break;
      case SVt_PVHV:	/* 11 */
        mg_type = 'P';
        clone = hv_clone (ref, depth);
        break;
      case SVt_PVBM:	/* 8 */
      case SVt_PVLV:	/* 9 */
      case SVt_PVCV:	/* 12 */
      case SVt_PVGV:	/* 13 */
      case SVt_PVFM:	/* 14 */
      case SVt_PVIO:	/* 15 */
        TRACEME(("default: type = 0x%x\n", SvTYPE (ref)));
        clone = SvREFCNT_inc(ref);  /* just return the ref */
        break;
      default:
        croak("unkown type: 0x%x", SvTYPE(ref));
    }

  if (SvRMAGICAL(ref) && (mg = mg_find(ref, mg_type)))
    {
      SV *tie = NULL;
      TRACEME(("magic scalar"));
      if(!mg)
        croak("couldn't find magic for scalar");
      tie = sv_clone(mg->mg_obj,-1);
      sv_magic((SV *) clone, tie, mg_type, 0, 0);
    }

  TRACEME(("storing ref = 0x%x clone = 0x%x\n", ref, clone));
  if (!hv_store(hseen, (char *) &ref, sizeof(ref), clone, 0))
    croak("couldn't store clone");

  TRACEME(("clone = 0x%x\n", clone));
  return clone;
}

MODULE = Clone		PACKAGE = Clone		

void
clone(self, depth=-1)
	SV *self
	int depth
	PREINIT:
	SV *    clone = &PL_sv_undef;
	PPCODE:
	hseen = newHV();
	TRACEME(("ref = 0x%x\n", self));
	clone = sv_clone(self, depth);
	{
	  HE * he;
	  hv_iterinit(hseen);
	  while (he = hv_iternext(hseen))
	    HeVAL(he) = &PL_sv_undef;
	}
	hv_undef(hseen);                /* Free seen object table */
	sv_free((SV *) hseen);  /* Free HV */
	EXTEND(SP,1);
	PUSHs(clone);
