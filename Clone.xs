#include <assert.h>

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static SV *hv_clone (SV *, int);
static SV *av_clone (SV *, int);
static SV *sv_clone (SV *, int);
static SV *rv_clone (SV *, int);
static SV *ref_of_clone (SV *, SV *);
static SV *clone_object (SV * , int );

static HV *hseen;

#if(0)
#define TRACEME(a) printf("%s:%d %s\n",__FUNCTION__, __LINE__, a)
#define TRACERF(a) printf("%s:%d 0x%x\n",__FUNCTION__, __LINE__, a)
#else
#define TRACEME(a)
#define TRACERF(a)
#endif

static SV *
hv_clone (SV * ref, int depth)
{
  HV *clone = newHV ();
  HV *self = (HV *) ref;
  HE *next = NULL;
  MAGIC *mg = NULL;
  I32 retlen = 0;
  char *key;
  SV *val;
  int recur = depth ? depth - 1 : 0;

  assert(SvTYPE(ref) == SVt_PVHV);

  TRACERF(ref);

  hv_iterinit (self);
  while (next = hv_iternext (self))
    {
      key = hv_iterkey (next, &retlen);
      val = hv_iterval (self, next);
      val = clone_object (val, recur);
      hv_store (clone, key, retlen, SvREFCNT_inc(val), 0);
    }

  if (SvRMAGICAL(ref) && (mg = mg_find(ref, 'P')))
    {
      SV *tie = NULL;
      TRACEME("magic hash");
      if(!mg)
        croak("couldn't find magic");
      tie = clone_object(mg->mg_obj,-1);
      sv_magic((SV *) clone, tie, 'P', 0, 0);
    }

  TRACERF(clone);
  return (SV *) clone;
}

static SV *
av_clone (SV * ref, int depth)
{
  AV *clone = newAV ();
  AV *self = (AV *) ref;
  MAGIC *mg = NULL;
  SV **svp;
  SV *val = NULL;
  I32 arrlen = 0;
  int i = 0;
  int recur = depth ? depth - 1 : 0;

  assert(SvTYPE(ref) == SVt_PVAV);

  TRACERF(ref);

  arrlen = av_len (self);
  av_extend (clone, arrlen);

  for (i = 0; i <= arrlen; i++)
    {
      svp = av_fetch (self, i, 0);
      if (svp)
	{
	  val = *svp;
          val = clone_object (val, recur);
	  av_store (clone, i, SvREFCNT_inc(val));
	}
    }

  if (SvRMAGICAL(ref) && (mg = mg_find(ref, 'P')))
    {
      SV *tie = NULL;
      TRACEME("magic array");
      if(!mg)
        croak("couldn't find magic");
      tie = clone_object(mg->mg_obj,-1);
      sv_magic((SV *) clone, tie, 'P', 0, 0);
    }

  TRACERF(clone);
  return (SV *) clone;
}

static SV *
sv_clone (SV * ref, int depth)
{
  SV *clone = NULL;
  SV *self = (SV *) ref;
  MAGIC *mg = NULL;

  assert(SvTYPE(ref) == SVt_PVMG
      || SvTYPE(ref) == SVt_IV
      || SvTYPE(ref) == SVt_NV
      || SvTYPE(ref) == SVt_PV
  );

  TRACERF(ref);

  clone = newSVsv (self);

  if (SvRMAGICAL(ref) && (mg = mg_find(ref, 'q')))
    {
      SV *tie = NULL;
      TRACEME("magic scalar");
      if(!mg)
        croak("couldn't find magic for scalar");
      tie = clone_object(mg->mg_obj,-1);
      sv_magic((SV *) clone, tie, 'q', 0, 0);
    }


  TRACERF(clone);
  return clone;
}

static SV *
rv_clone (SV * ref, int depth)
{
  SV *clone = NULL;
  SV *rv = NULL;

  assert(SvROK(ref) && (SvTYPE(ref) == SVt_RV));

  TRACERF(ref);

  if (!SvROK (ref))
    return NULL;

  TRACERF(SvRV (ref));

  clone = clone_object (SvRV(ref), depth);

  if (SvRMAGICAL(ref) && (mg_find(ref, 'q')))
    TRACEME("magic ref?");

  TRACERF(clone);
  return ref_of_clone (ref, clone);
}

static SV *
ref_of_clone (SV * orig, SV * clone)
{
  SV *rv = NULL;
  if (sv_isobject (orig))
    {
      // rv = newRV_inc (clone); // faster, but causes memory leak.
      rv = newRV_noinc (clone);
      rv = sv_2mortal (sv_bless (rv, SvSTASH (SvRV (orig))));
    }
  else
    rv = newRV_inc (clone);
    

  TRACERF(rv);
  return rv;
}

static SV *
clone_object (SV * ref, int depth)
{
  SV *clone = ref;

  TRACERF(ref);

  if (depth)
    {
      SV **svh = hv_fetch(hseen, (char *) &ref, sizeof(ref), FALSE);

      if(svh)
        {
          TRACEME("fetch ref");
          TRACERF(ref);
          TRACERF(*svh);
          return SvREFCNT_inc(*svh);
          // return *svh;
        }

      TRACEME("switch:");
      switch (SvTYPE (ref))
        {
          case SVt_NULL:
            TRACEME("sv_null");
            TRACERF(ref);
            // clone = newSVsv(&PL_sv_undef);
            clone = sv_2mortal(newSVsv(&PL_sv_undef));
            break;
          case SVt_PVHV:
            clone = hv_clone (ref, depth);
            break;
          case SVt_PVAV:
            clone = av_clone (ref, depth);
            break;
          case SVt_PVMG:
            TRACEME("magic scalar");
          case SVt_IV:
            TRACEME("int scalar");
          case SVt_NV:
            TRACEME("double scalar");
          case SVt_PV:
            TRACEME("string scalar");
            clone = sv_clone(ref, depth);
            break;
          case SVt_RV:
            TRACEME("ref scalar");
            TRACERF(ref);
            clone = rv_clone(ref, depth);
            break;
          default:
            // just copy the ref
            TRACEME("default");
            TRACERF(ref);
            TRACERF(SvTYPE (ref));
            // clone = newSVsv(ref);
            clone = sv_2mortal(newSVsv(ref));
            break;
        }
      TRACEME("storing ref");
      TRACERF(ref);
      TRACERF(clone);
      if (!hv_store(hseen, (char *) &ref, sizeof(ref), clone, 0))
         croak("couldn't store clone");
    }
  else
     clone = SvREFCNT_inc(ref);

  TRACEME("ref and clone:");
  TRACERF(ref);
  TRACERF(clone);
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
	TRACERF(self);
	// clone = clone_object(self, depth);
	clone = rv_clone(self, depth);
	{
	  HE * he;
	  hv_iterinit(hseen);
	  while (he = hv_iternext(hseen))
	    HeVAL(he) = &PL_sv_undef;
	}
	hv_undef(hseen);                /* Free seen object table */
	sv_free((SV *) hseen);  /* Free HV */
	TRACERF(&PL_sv_undef);
	EXTEND(SP,1);
	PUSHs(clone);
