## Set the top level module
set_top algo_top_SLRAB

#### Add source code
add_files src/algo_top_parameters_SLRAB.h
add_files src/algo_top_SLRAB.h
add_files src/algo_top_SLRAB.cpp
add_files src/bitonicSort16_SLRAB.h
add_files src/bitonicSort16_SLRAB.cpp

### Add testbed files
add_files -tb src/algo_top_tb_SLRAB.cpp
add_files -tb ../../common/APxLinkData.hh
add_files -tb ../../common/APxLinkData.cpp

### Add test input files
add_files -tb data/test_in.txt
add_files -tb data/test_out_ref.txt
