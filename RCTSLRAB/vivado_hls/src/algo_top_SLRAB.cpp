#include "algo_top_SLRAB.h"
#include "algo_top_parameters_SLRAB.h"
#include "bitonicSort16_SLRAB.h"

void prsInLinksSLRA(ap_uint<384> link_in[N_INPUT_LINKS_SLRA], Cluster clusterSLRA[6], tower_t towerSLRA[36]){
            #pragma HLS ARRAY_PARTITION variable=link_in complete dim=0
            #pragma HLS ARRAY_PARTITION variable=clusterSLRA complete dim=0
            #pragma HLS ARRAY_PARTITION variable=towerSLRA complete dim=0

        ap_uint<32> start = 0;
        ap_uint<32> end = 11;

        for(loop i=0; i<16; i++){
                #pragma HLS unroll
                towerSLRA[i] = tower_t(link_in[0].range(end, start), 0, 0);
                towerSLRA[i+16] = tower_t(link_in[1].range(end, start), 0, 0);
                start += 12;
                end += 12;
        }

        for(loop i=0; i<4; i++){
                towerSLRA[i+32] = tower_t(0, 0, 0);
        }


        start = 192;
        for(loop i=0; i<3; i++){
                end = start + 59;
                clusterSLRA[i].data     = link_in[0].range(end, start);
                clusterSLRA[i+3].data   = link_in[1].range(end, start);
                start = start + 60;
        }

}

void prsInLinksSLRB(ap_uint<384> link_in[N_INPUT_LINKS_SLRB], Cluster clusterSLRB[6], tower_t towerSLRB[36], towerHCAL HCALtower[72]){
            #pragma HLS ARRAY_PARTITION variable=link_in complete dim=0
            #pragma HLS ARRAY_PARTITION variable=clusterSLRB complete dim=0
            #pragma HLS ARRAY_PARTITION variable=towerSLRB complete dim=0
            #pragma HLS ARRAY_PARTITION variable=HCALtower complete dim=0

        ap_uint<32> start = 0;

        for(loop i=0; i<6; i++){
                #pragma HLS UNROLL
                ap_uint<32> end = start + 11;
                towerSLRB[i]    = tower_t(link_in[0].range(end, start), 0, 0);
                towerSLRB[i+6]  = tower_t(link_in[1].range(end, start), 0, 0);
                towerSLRB[i+12] = tower_t(link_in[2].range(end, start), 0, 0);
                towerSLRB[i+18] = tower_t(link_in[3].range(end, start), 0, 0);
                towerSLRB[i+24] = tower_t(link_in[4].range(end, start), 0, 0);
                towerSLRB[i+30] = tower_t(link_in[5].range(end, start), 0, 0);
                start += 12;
                }

        start = 72;
        for(loop i=0; i<12; i++){
                #pragma HLS UNROLL
                ap_uint<32> end = start + 9;
                HCALtower[i]    = towerHCAL(link_in[0].range(end, start));
                HCALtower[i+12] = towerHCAL(link_in[1].range(end, start));
                HCALtower[i+24] = towerHCAL(link_in[2].range(end, start));
                HCALtower[i+36] = towerHCAL(link_in[3].range(end, start));
                HCALtower[i+48] = towerHCAL(link_in[4].range(end, start));
                HCALtower[i+60] = towerHCAL(link_in[5].range(end, start));
                start += 10;
        }

        start = 192;
        for(loop i=0; i<6; i++){
                #pragma HLS unroll
                ap_uint<32> end = start + 59;
                clusterSLRB[i].data = link_in[i].range(end, start);
        }
}

void stitchClustersSLRAB(Cluster SLRA[6],Cluster SLRB[6], Cluster output[Nbclusters]){
        #pragma HLS ARRAY_PARTITION variable=SLRA complete dim=0
        #pragma HLS ARRAY_PARTITION variable=SLRB complete dim=0
        #pragma HLS ARRAY_PARTITION variable=output complete dim=0

//there is only one boundary to check, last eta raw of SLRB, and
//first raw of SLRA
       for(int i=0; i<Nbclusters; i++){
        #pragma HLS UNROLL
         if(i < 6) output[i] = SLRA[i] ;
         else if(i < 12) output[i] = SLRB[i-6] ;
       }

       for(int i=10; i<Nbclusters; i++){
        #pragma HLS UNROLL
        if(output[i].clusterEnergy() > 0){
        if(output[i].towerEta() == 8 && output[i].clusterEta() == 4){
         for(int k=0; k<6; k++){
          if(output[k].clusterEnergy() > 0 && output[k].towerEta() == 9 && output[k].clusterEta() == 0){
          ap_uint<5> phi1 = output[i].towerPhi()*5 + output[i].clusterPhi() ;
          ap_uint<5> phi2 = output[k].towerPhi()*5 + output[k].clusterPhi() ;
          ap_uint<5> dPhi ; dPhi=(phi1 > phi2)?(phi1-phi2):(phi2-phi1) ;
           if( dPhi < 2 ) {
           ap_uint<12> one = output[i].clusterEnergy() ;
           ap_uint<12> two = output[k].clusterEnergy() ;
           ap_uint<12> sum = one+two ;
           ap_uint<15> et5x5 = output[i].et5x5() + output[k].et5x5() ;
           ap_uint<15> et2x5 = output[i].et2x5() + output[k].et2x5() ;
              if (one > two){
 output[i] = Cluster(sum, output[i].towerEta(), output[i].towerPhi(), output[i].clusterEta(), output[i].clusterPhi(), output[i].satur(), et5x5, et2x5, output[i].brems()) ;
 output[k] = Cluster(0, 0, 0, 0, 0, 0, 0, 0, 0) ;
                            }
              else {
 output[k] = Cluster(sum, output[k].towerEta(), output[k].towerPhi(), output[k].clusterEta(), output[k].clusterPhi(), output[k].satur(), et5x5, et2x5, output[k].brems()) ;
 output[i] = Cluster(0, 0, 0, 0, 0, 0, 0, 0, 0) ;
                   }
                 }}
           }}
          }
         }



}

ap_uint<4> getHoverESLRAB(ap_uint<12> ECAL, ap_uint<12> HCAL){

ap_uint<4> hoeOut ;
ap_uint<1> hoeLSB = 0 ;
ap_uint<3> hoe = 0 ;
ap_uint<12> A;
ap_uint<12> B;

A = (ECAL > HCAL)?ECAL:HCAL;
B = (ECAL > HCAL)?HCAL:ECAL;

if( ECAL == 0 || HCAL == 0 || HCAL >= ECAL) hoeLSB = 0 ;
else hoeLSB = 1 ;
 if( A > B ){
  if(A > 2*B) hoe = 0x001 ;
  if(A > 4*B) hoe = 0x010 ;
  if(A > 8*B) hoe = 0x011 ;
  if(A > 16*B) hoe = 0x100 ;
  if(A > 32*B) hoe = 0x101 ;
  if(A > 64*B) hoe = 0x110 ;
  if(A > 128*B) hoe = 0x111 ;
 }

hoeOut = hoeLSB | (hoe << 1) ;

return hoeOut ;

}

void algo_top_SLRAB(ap_uint<384> link_inSLRA[N_INPUT_LINKS_SLRA], ap_uint<384> link_inSLRB[N_INPUT_LINKS_SLRB], ap_uint<384> link_out[N_OUTPUT_LINKS]){
#pragma HLS ARRAY_PARTITION variable=link_inSLRA complete dim=0
#pragma HLS ARRAY_PARTITION variable=link_inSLRB complete dim=0
#pragma HLS ARRAY_PARTITION variable=link_out complete dim=0
#pragma HLS PIPELINE II=6
#pragma HLS INTERFACE ap_ctrl_hs port=return

//#pragma HLS latency min=100

      Cluster clusterSLRA[6] ;
      tower_t towerSLRA[36] ;
      Cluster clusterSLRB[6] ;
      tower_t towerSLRB[36] ;
      towerHCAL HCALtowers[72] ;
      #pragma HLS ARRAY_PARTITION variable=clusterSLRA complete dim=0
      #pragma HLS ARRAY_PARTITION variable=towerSLRA complete dim=0
      #pragma HLS ARRAY_PARTITION variable=clusterSLRB complete dim=0
      #pragma HLS ARRAY_PARTITION variable=towerSLRB complete dim=0
      #pragma HLS ARRAY_PARTITION variable=HCALtowers complete dim=0

      prsInLinksSLRA(link_inSLRA, clusterSLRA, towerSLRA) ;
      prsInLinksSLRB(link_inSLRB, clusterSLRB, towerSLRB, HCALtowers) ;

//        for(loop i=0; i<36; i++) cout << "B " << i << " i " << towerSLRB[i].et() << endl ;
//        for(loop i=0; i<36; i++) cout << "A " << i << " i " << towerSLRA[i].et() << endl ;
//        for(loop i=0; i<72; i++) cout << "HCAL " << i << " i " << HCALtowers[i].et << endl ;

// stitch clusters SLRA and B, we have 6 and 6, maximum 12, but we reserve 16
// to order them in bitonic sorter
// in sort_clusterOut we use 10-15

      Cluster sort_clusterAandB[Nbclusters] ;
      #pragma HLS ARRAY_PARTITION variable=sort_clusterAandB complete dim=0
      stitchClustersSLRAB(clusterSLRA,clusterSLRB, sort_clusterAandB);

//     for(loop i=0; i<6; i++) cout << "Cluster i " << i << " A  " << clusterSLRA[i].clusterEnergy() << " B " << clusterSLRB[i].clusterEnergy() << " A or B " << sort_clusterAandB[i].clusterEnergy() << endl ;
//    for(loop i=6; i<16; i++) cout << "Cluster i " << i << " A or B " << sort_clusterAandB[i].clusterEnergy() << endl ;

// now we sort the clusters

      Cluster sort_clusterOutput[Nbclusters] ;
      #pragma HLS ARRAY_PARTITION variable=sort_clusterOutput complete dim=0

      bitonicSort16_SLRAB(sort_clusterAandB, sort_clusterOutput);

// we want to keep 8 most energetic and 4 we should put back in towers
// we need to check only 8 towers and 4 clusters
// towerEt 32 33 34 35 and towerSLRA 0(36) 1 2 3
// and clusters 4 5 6 7
        ap_uint<12> SumE1[7] ;
        ap_uint<12> SumE2[7] ;
        ap_uint<12> SumE3[7] ;
        ap_uint<12> SumEall1 ;
        ap_uint<12> SumEall2 ;
        ap_uint<12> SumEall3 ;


        for(loop i=32; i<36; i++){
                #pragma HLS UNROLL
           SumE1[0] = towerSLRB[i].et() ;
         for(loop k=4; k<8; k++){
                #pragma HLS UNROLL
          if(sort_clusterOutput[k].clusterEnergy() > 0 && sort_clusterOutput[k].towerEta()*4+sort_clusterOutput[k].towerPhi() == i){
          SumE1[k-3] = sort_clusterOutput[k].clusterEnergy() ;
          sort_clusterOutput[k] = Cluster(0, 0, 0, 0, 0, 0, 0, 0, 0) ;
          }
          else SumE1[k-3] = 0 ;
         }
          SumEall1 = SumE1[0] + SumE1[1] + SumE1[2] + SumE1[3] + SumE1[4] ;
          towerSLRB[i] = tower_t(SumEall1,0,0) ;
        }

        for(loop i=0; i<4; i++){
                #pragma HLS UNROLL
           SumE1[0] = towerSLRA[i].et() ;
         for(loop k=4; k<8; k++){
                #pragma HLS UNROLL
          if(sort_clusterOutput[k].clusterEnergy() > 0 && sort_clusterOutput[k].towerEta()*4+sort_clusterOutput[k].towerPhi() == i+36){
          SumE1[k-3] = sort_clusterOutput[k].clusterEnergy() ;
          sort_clusterOutput[k] = Cluster(0, 0, 0, 0, 0, 0, 0, 0, 0) ;
          }
          else SumE1[k-3] = 0 ;
         }
          SumEall1 = SumE1[0] + SumE1[1] + SumE1[2] + SumE1[3] + SumE1[4] ;
          towerSLRA[i] = tower_t(SumEall1,0,0) ;
        }

// now we need to add hcal to ecal in towers

       SumEH SumEH1[12], SumEH2[12], SumEH3[12], SumEH4[12], SumEH5[12], SumEH6[12] ;
      #pragma HLS ARRAY_PARTITION variable=SumEH1 complete dim=0
      #pragma HLS ARRAY_PARTITION variable=SumEH2 complete dim=0
      #pragma HLS ARRAY_PARTITION variable=SumEH3 complete dim=0
      #pragma HLS ARRAY_PARTITION variable=SumEH4 complete dim=0
      #pragma HLS ARRAY_PARTITION variable=SumEH5 complete dim=0
      #pragma HLS ARRAY_PARTITION variable=SumEH6 complete dim=0

       for(loop i=0 ; i<12; i++){
       #pragma HLS UNROLL

       SumEH1[i].et = towerSLRB[i].et() + HCALtowers[i].et;
       SumEH1[i].hoe = getHoverESLRAB(towerSLRB[i].et(),HCALtowers[i].et);

       SumEH2[i].et = towerSLRB[i+12].et() + HCALtowers[i+12].et;
       SumEH2[i].hoe = getHoverESLRAB(towerSLRB[i+12].et(),HCALtowers[i+12].et);

       SumEH3[i].et = towerSLRB[i+24].et() + HCALtowers[i+24].et;
       SumEH3[i].hoe = getHoverESLRAB(towerSLRB[i+24].et(),HCALtowers[i+24].et);

       SumEH4[i].et = towerSLRA[i].et() + HCALtowers[i+36].et;
       SumEH4[i].hoe = getHoverESLRAB(towerSLRA[i].et(),HCALtowers[i+36].et);

       SumEH5[i].et = towerSLRA[i+12].et() + HCALtowers[i+48].et;
       SumEH5[i].hoe = getHoverESLRAB(towerSLRA[i+12].et(),HCALtowers[i+48].et);

       SumEH6[i].et = towerSLRA[i+24].et() + HCALtowers[i+60].et;
       SumEH6[i].hoe = getHoverESLRAB(towerSLRA[i+24].et(),HCALtowers[i+60].et);
       }


//        for(loop i=0; i<12; i++) cout << "OUT " << i << " i " << SumEH1[i].et << " " << SumEH2[i].et << " " << SumEH3[i].et << " " << SumEH4[i].et << " " << SumEH5[i].et << " " << SumEH6[i].et  << endl ;
//          for(loop i=0; i<16; i++) cout << "Cluster i " << i << "  " << sort_clusterOutput[i].clusterEnergy() << endl ;

        /*---------------------------------link 0, 1, 2, 3 ------------------------------------*/
        ap_uint<32> start1_1 = 0;
        link_out[0] = 0;
        link_out[1] = 0;
        link_out[2] = 0;
        link_out[3] = 0;

        for(loop oLink=0; oLink<12; oLink += 4){
        #pragma HLS UNROLL
            ap_uint<32> end = start1_1 + 14;
            link_out[0].range(end, start1_1) = SumEH1[oLink].hoe | (((ap_uint<16>) SumEH1[oLink].et ) << 4) ;
            link_out[1].range(end, start1_1) = SumEH1[oLink+1].hoe  | (((ap_uint<16>) SumEH1[oLink+1].et ) << 4) ;
            link_out[2].range(end, start1_1) = SumEH1[oLink+2].hoe  | (((ap_uint<16>) SumEH1[oLink+2].et ) << 4) ;
            link_out[3].range(end, start1_1) = SumEH1[oLink+3].hoe  | (((ap_uint<16>) SumEH1[oLink+3].et ) << 4) ;
            start1_1 += 15;
        }


        for(loop oLink=0; oLink<12; oLink += 4){
        #pragma HLS UNROLL
            ap_uint<32> end = start1_1 + 14;
            link_out[0].range(end, start1_1) = SumEH2[oLink].hoe | (((ap_uint<16>) SumEH2[oLink].et ) << 4) ;
            link_out[1].range(end, start1_1) = SumEH2[oLink+1].hoe  | (((ap_uint<16>) SumEH2[oLink+1].et ) << 4) ;
            link_out[2].range(end, start1_1) = SumEH2[oLink+2].hoe  | (((ap_uint<16>) SumEH2[oLink+2].et ) << 4) ;
            link_out[3].range(end, start1_1) = SumEH2[oLink+3].hoe  | (((ap_uint<16>) SumEH2[oLink+3].et ) << 4) ;
            start1_1 += 15;
        }


        for(loop oLink=0; oLink<12; oLink += 4){
        #pragma HLS UNROLL
            ap_uint<32> end = start1_1 + 14;
            link_out[0].range(end, start1_1) = SumEH3[oLink].hoe | (((ap_uint<16>) SumEH3[oLink].et ) << 4) ;
            link_out[1].range(end, start1_1) = SumEH3[oLink+1].hoe  | (((ap_uint<16>) SumEH3[oLink+1].et ) << 4) ;
            link_out[2].range(end, start1_1) = SumEH3[oLink+2].hoe  | (((ap_uint<16>) SumEH3[oLink+2].et ) << 4) ;
            link_out[3].range(end, start1_1) = SumEH3[oLink+3].hoe  | (((ap_uint<16>) SumEH3[oLink+3].et ) << 4) ;
            start1_1 += 15;
        }


        for(loop oLink=0; oLink<12; oLink += 4){
        #pragma HLS UNROLL
            ap_uint<32> end = start1_1 + 14;
            link_out[0].range(end, start1_1) = SumEH4[oLink].hoe | (((ap_uint<16>) SumEH4[oLink].et ) << 4) ;
            link_out[1].range(end, start1_1) = SumEH4[oLink+1].hoe  | (((ap_uint<16>) SumEH4[oLink+1].et ) << 4) ;
            link_out[2].range(end, start1_1) = SumEH4[oLink+2].hoe  | (((ap_uint<16>) SumEH4[oLink+2].et ) << 4) ;
            link_out[3].range(end, start1_1) = SumEH4[oLink+3].hoe  | (((ap_uint<16>) SumEH4[oLink+3].et ) << 4) ;
            start1_1 += 15;
        }


        for(loop oLink=0; oLink<12; oLink += 4){
        #pragma HLS UNROLL
            ap_uint<32> end = start1_1 + 14;
            link_out[0].range(end, start1_1) = SumEH5[oLink].hoe | (((ap_uint<16>) SumEH5[oLink].et ) << 4) ;
            link_out[1].range(end, start1_1) = SumEH5[oLink+1].hoe  | (((ap_uint<16>) SumEH5[oLink+1].et ) << 4) ;
            link_out[2].range(end, start1_1) = SumEH5[oLink+2].hoe  | (((ap_uint<16>) SumEH5[oLink+2].et ) << 4) ;
            link_out[3].range(end, start1_1) = SumEH5[oLink+3].hoe  | (((ap_uint<16>) SumEH5[oLink+3].et ) << 4) ;
            start1_1 += 15;
        }

        for(loop oLink=0; oLink<8; oLink += 4){
        #pragma HLS UNROLL
            ap_uint<32> end = start1_1 + 14;
            link_out[0].range(end, start1_1) = SumEH6[oLink].hoe | (((ap_uint<16>) SumEH6[oLink].et ) << 4) ;
            link_out[1].range(end, start1_1) = SumEH6[oLink+1].hoe  | (((ap_uint<16>) SumEH6[oLink+1].et ) << 4) ;
            link_out[2].range(end, start1_1) = SumEH6[oLink+2].hoe  | (((ap_uint<16>) SumEH6[oLink+2].et ) << 4) ;
            link_out[3].range(end, start1_1) = SumEH6[oLink+3].hoe  | (((ap_uint<16>) SumEH6[oLink+3].et ) << 4) ;
            start1_1 += 15;
        }

        for(loop oLink=8; oLink<16; oLink += 4){
        #pragma HLS UNROLL
            ap_uint<32> end = start1_1 + 59;
            link_out[0].range(end, start1_1) = sort_clusterOutput[oLink];
            link_out[1].range(end, start1_1) = sort_clusterOutput[oLink+1];
            link_out[2].range(end, start1_1) = sort_clusterOutput[oLink+2];
            link_out[3].range(end, start1_1) = sort_clusterOutput[oLink+3];
            start1_1 += 60;
        }

}

