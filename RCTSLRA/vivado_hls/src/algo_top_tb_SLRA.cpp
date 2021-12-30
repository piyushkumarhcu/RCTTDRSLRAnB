#include <stdio.h>
#include <stdlib.h>
#include <cstdlib>
#include <stdint.h>
#include <unistd.h>

#include <iostream>
#include <fstream>
#include <iomanip>
#include <string>
#include "algo_top_SLRA.h"
#include "algo_top_parameters_SLRA.h"

using namespace std;

int main() {

	ap_uint<384> link_in[N_INPUT_LINKS];
	ap_uint<384> link_out[N_OUTPUT_LINKS];

	link_in[0]  = "0x00000000000E00000000000000000000000000000000000000000000000000000000000000000000000000000000000A";
	link_in[1]  = 0;
	link_in[2]  = 0;
	link_in[3]  = 0;
	link_in[4]  = "0x000000000000007800000000000000000000000000000000000000000000000000000000000000000000000000000000";
	link_in[5]  = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000B";
	link_in[6]  = 0;
	link_in[7]  = 0;
	link_in[8]  = 0;
	link_in[9]  = 0;
	link_in[10] = 0;
	link_in[11] = "0x000000000000000000000000050000000000000000000000000000000000000000000000003000000000000000000000";
	link_in[12] = 0;
	link_in[13] = 0;
	link_in[14] = 0;
	link_in[15] = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003C000";
	link_in[16] = 0;
	link_in[17] = 0;
	link_in[18] = 0;
	link_in[19] = 0;
	link_in[20] = "0x000000000000000000000000000000000000000000000000000000000000000000240000000000000000000000000000";
	link_in[21] = 0;
	link_in[22] = "0x0000000000000000000002C0000000000000000000000000000000000000000000000000000000000000000000000000";
	link_in[23] = 0;
	link_in[24] = 0;
	link_in[25] = "0x00000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000C";
	link_in[26] = 0;
	link_in[27] = 0;
	link_in[28] = 0;
	link_in[29] = 0;
	link_in[30] = 0;
	link_in[31] = 0;



	// Run the algorithm

	  algo_top_SLRA(link_in, link_out);

	  cout << hex << "link_out[0]: " << link_out[0] << endl;
	  cout << hex << "link_out[1]: " << link_out[1] << endl;

	  cout << "printing towers et" << endl;

	  		ap_uint<32> start1_1 = 0;
	  		for(loop oLink=0; oLink<16; oLink++){
	  			size_t end = start1_1 + 11;
	  			cout << link_out[0].range(end, start1_1) << " " ;
                if(oLink%4 == 3) cout << endl ;
	  			start1_1 += 12;
	  		}

	  		ap_uint<32> start2_1 = 0;
	  		for(loop oLink=0; oLink<16; oLink++){
	  			size_t end = start2_1 + 11;
	  			cout << link_out[1].range(end, start2_1) << " " ;
	  		    if(oLink%4 == 3) cout << endl ;
	  		    start2_1 += 12;
	  		}

	  		cout << "printing cluster et" << endl;

	  		cout << link_out[0].range(203, 192) << endl;
	  		cout << link_out[0].range(263, 252) << endl;
	  		cout << link_out[0].range(323, 312) << endl;

	  		cout << link_out[1].range(203, 192) << endl;
	  		cout << link_out[1].range(263, 252) << endl;
	  		cout << link_out[1].range(323, 312) << endl;


	  		return 0;

}



