
#ifndef _BITONICSORT16_SLRA_H_
#define _BITONICSORT16_SLRA_H_

#include <iostream>
#include "ap_int.h"
#include "algo_top_SLRA.h"
#include "algo_top_parameters_SLRA.h"
#define Nbclusters 16

using namespace std;

class GreaterSmaller{
public:
    Cluster greater, smaller;
};

void bitonicSort16_SLRA(Cluster in[Nbclusters], Cluster out[Nbclusters]);

#endif
