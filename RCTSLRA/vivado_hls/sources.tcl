## Set the top level module
set_top algo_top_SLRA

#### Add source code
add_files src/algo_top_parameters_SLRA.h
add_files src/algo_top_SLRA.h
add_files src/algo_top_SLRA.cpp
add_files src/bitonicSort16_SLRA.h
add_files src/bitonicSort16_SLRA.cpp

### Add testbed files
add_files -tb src/algo_top_tb_SLRA.cpp
add_files -tb ../../common/APxLinkData.hh
add_files -tb ../../common/APxLinkData.cpp

### Add test input files
add_files -tb data/test_in.txt
add_files -tb data/test_out_ref.txt
