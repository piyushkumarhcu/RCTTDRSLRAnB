## Set the top level module
set_top algo_top_SLRB

#### Add source code
add_files src/algo_top_parameters_SLRB.h
add_files src/algo_top_SLRB.h
add_files src/algo_top_SLRB.cpp
add_files src/bitonicSort16_SLRB.h
add_files src/bitonicSort16_SLRB.cpp

### Add testbed files
add_files -tb src/algo_top_tb_SLRB.cpp
add_files -tb ../../common/APxLinkData.hh
add_files -tb ../../common/APxLinkData.cpp

### Add test input files
add_files -tb data/test_in.txt
add_files -tb data/test_out_ref.txt
