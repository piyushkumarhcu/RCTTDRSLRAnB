
#ifndef _BITONICSORT16_SLRAB_H_
#define _BITONICSORT16_SLRAB_H_

#include <iostream>
#include "ap_int.h"
#include "algo_top_SLRAB.h"
#include "algo_top_parameters_SLRAB.h"
#define Nbclusters 16

using namespace std;

class GreaterSmaller{
public:
    Cluster greater, smaller;
};

void bitonicSort16_SLRAB(Cluster in[Nbclusters], Cluster out[Nbclusters]);

#endif
