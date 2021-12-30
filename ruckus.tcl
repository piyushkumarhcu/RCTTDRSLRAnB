# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# # Load Source Code
loadSource -path "$::DIR_PATH/rtl/RCTAlgoWrapperSLR1.vhd"
loadSource -path "$::DIR_PATH/rtl/RCTAlgoWrapperSLR2.vhd"
loadSource -path "$::DIR_PATH/rtl/RCTAlgoWrapperSLRAB.vhd"
loadSource -path "$::DIR_PATH/rtl/algoTopWrapper.vhd"

loadSource -dir "$::DIR_PATH/RCTSLRA/vivado_hls/proj/solution1/impl/ip/hdl/vhdl/"
loadSource -dir "$::DIR_PATH/RCTSLRB/vivado_hls/proj/solution1/impl/ip/hdl/vhdl/"
loadSource -dir "$::DIR_PATH/RCTSLRAB/vivado_hls/proj/solution1/impl/ip/hdl/vhdl/"

