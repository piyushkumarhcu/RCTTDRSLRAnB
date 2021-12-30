
#ifndef _BITONICSORT16_SLRB_H_
#define _BITONICSORT16_SLRB_H_

#include <iostream>
#include "ap_int.h"
#include "algo_top_SLRB.h"
#include "algo_top_parameters_SLRB.h"
#define Nbclusters 16

using namespace std;

class GreaterSmaller{
public:
    Cluster greater, smaller;
};

void bitonicSort16_SLRB(Cluster in[Nbclusters], Cluster out[Nbclusters]);

#endif
