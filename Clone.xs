#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

SV *hv_clone(SV *, int);
SV *av_clone(SV *, int);

SV *
hv_clone(SV *ref, int depth)
  {
    HV *clone = newHV();
    HV *self = NULL;
    HE *next = NULL;
    int recur = 0;
    I32 retlen = 0;
    char *key;
    SV *val;

    if (!SvROK(ref))
      return NULL;

    recur = depth ? depth - 1 : 0;
    self = (HV *) SvRV(ref);

    hv_iterinit(self);
    while (next = hv_iternext(self))
      {
        key = hv_iterkey(next, &retlen);
        val = hv_iterval(self, next);
        if (depth && SvROK(val))
	  {
	    SV *ref;
	    // printf("ref %s => %s\n", key, SvPV(val,PL_na));
	    switch(SvTYPE(SvRV(val)))
              {
	        case SVt_PVHV:
                  ref = hv_clone(val, recur);
		  break;
		case SVt_PVAV:
                  ref = av_clone(val, recur);
		  break;
		default:
                  ref = val;
		  // printf("Hash = %s\n", SvPV(val,PL_na));
		  break;
              }
	    hv_store(clone, key, retlen, newSVsv(ref), 0);
	  }
	else
	  {
	    hv_store(clone, key, retlen, newSVsv(val), 0);
	  }
      }

    val = newRV_noinc((SV *) clone);
    if (sv_isobject(ref))
      val = sv_2mortal(sv_bless(val,SvSTASH(SvRV(ref))));
/*
      val = sv_bless(val,SvSTASH(SvRV(ref)));
*/

    return val;
  }

SV *
av_clone(SV *ref, int depth)
  {
    AV *clone = newAV();
    AV *self = NULL;
    int recur = 0;
    I32 arrlen = 0;
    SV **svp;
    SV *val;
    int i = 0;

    if (!SvROK(ref))
      return NULL;

    recur = depth ? depth - 1 : 0;
    self = (AV *) SvRV(ref);

    arrlen = av_len(self);
    av_extend(clone, arrlen);

    for (i = 0; i <= arrlen; i++)
      {
        svp = av_fetch(self, i, 0);
        if(svp)
          {
            val = *svp;
            if (depth && SvROK(val))
	      {
	        switch(SvTYPE(SvRV(val)))
                  {
	            case SVt_PVHV:
                      val = hv_clone(val, recur);
		      break;
		    case SVt_PVAV:
                      val = av_clone(val, recur);
		      break;
		    default:
		      break;
                  }
	      }
            av_store(clone, i, newSVsv(val));
          }
      }

    val = newRV_noinc((SV *) clone);
    if (sv_isobject(ref))
      val = sv_2mortal(sv_bless(val,SvSTASH(SvRV(ref))));

    return val;
  }

MODULE = Clone		PACKAGE = Clone		

void
clone(self, depth=-1)
	SV *self
	int depth
	PREINIT:
	SV *    clone = NULL;
	SV *    ref = NULL;
	PPCODE:
	if(SvROK(self))
	  {
	    switch(SvTYPE(SvRV(self)))
              {
	        case SVt_PVHV:
	          clone = hv_clone(self, depth);
		  break;
		case SVt_PVAV:
	          clone = av_clone(self, depth);
		  break;
		default:
		  croak("Sorry, not a hash or array reference");
		  break;
              }
	  }
	EXTEND(SP,1);
	PUSHs(clone);

