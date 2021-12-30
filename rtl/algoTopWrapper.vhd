library IEEE;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

entity algoTopWrapper is
  generic (
    N_INPUT_STREAMS  : integer := 96;
    N_OUTPUT_STREAMS : integer := 96
    );
  port (
    -- Algo Control/Status Signals
    algoClk   : in  sl;
    algoRst   : in  sl;
    algoStart : in  sl;
    algoDone  : out sl := '0';
    algoIdle  : out sl := '0';
    algoReady : out sl := '0';

    -- AXI-Stream In/Out Ports

    axiStreamFromSLR1   : in    AxiStreamMasterArray(0 to 1);
    axiStreamIn         : in    AxiStreamMasterArray(0 to N_INPUT_STREAMS-1);
    axiStreamOut        : out   AxiStreamMasterArray(0 to N_OUTPUT_STREAMS-1) := (others => AXI_STREAM_MASTER_INIT_C)
    );

end algoTopWrapper;

architecture rtl of algoTopWrapper is

  constant N_INPUT_STREAMS_XLA_SLR1     : integer := 32;
  constant N_OUTPUT_STREAMS_XLA_SLR1    : integer := 2;

  constant N_INPUT_STREAMS_XLA_SLR2     : integer := 38;
  constant N_OUTPUT_STREAMS_XLA_SLR2    : integer := 6;

  constant N_OUTPUT_STREAMS_XLA_SLRAB   : integer := 4;

  signal axiStreamInSLR1                : AxiStreamMasterArray(0 to N_INPUT_STREAMS_XLA_SLR1-1);
  signal axiStreamOutSLR1               : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR1-1);

  signal axiStreamInSLR2                : AxiStreamMasterArray(0 to N_INPUT_STREAMS_XLA_SLR2-1);
  signal axiStreamOutSLR2               : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);

  signal axiStreamInSLRA                : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR1-1);
  signal axiStreamInReg1SLRB            : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);
  signal axiStreamInReg2SLRB            : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);
  signal axiStreamInReg3SLRB            : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);
  signal axiStreamInReg4SLRB            : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);
  signal axiStreamInReg5SLRB            : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);
  signal axiStreamInReg6SLRB            : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);
  signal axiStreamInReg7SLRB            : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLR2-1);
 
  signal axiStreamOutSLRAB              : AxiStreamMasterArray(0 to N_OUTPUT_STREAMS_XLA_SLRAB-1);

  signal algoRstD1      : sl;
  signal algoStartSLR12 : sl;
  signal algoStartSLR0  : sl := '0';
  signal algoStartD1    : sl := '0';
  signal algoStartD2    : sl := '0';
  signal algoStartD3    : sl := '0';
  signal algoStartD4    : sl := '0';

  constant SLR1_INPUT_MAP_C : IntegerArray(0 to N_INPUT_STREAMS_XLA_SLR1-1) := (
  --sector 1
    0  => 12,
    1  => 13,
    2  => 14,
    3  => 15,
    4  => 16,
    5  => 17,
    6  => 18,
    7  => 19,
    8  => 20,
    9  => 21,
    10 => 22,
    11 => 23,
    12 => 24,
    13 => 25,
    14 => 26,
    15 => 27,

   --sector 4
    16 => 56,
    17 => 57,
    18 => 58,
    19 => 59,
    20 => 60,
    21 => 61,
    22 => 62,
    23 => 63,
    24 => 64,
    25 => 65,
    26 => 66,
    27 => 67,
    28 => 68,
    29 => 69,
    30 => 70,
    31 => 71
);

  constant SLR1_OUTPUT_MAP_C : IntegerArray(0 to N_OUTPUT_STREAMS_XLA_SLR1-1) := (
  --sector 4
    0  => 74,
    1  => 75
    );

  constant SLR2_INPUT_MAP_C : IntegerArray(0 to N_INPUT_STREAMS_XLA_SLR2-1) := (
  --sector 2
    0  => 28,
    1  => 29,
    2  => 30,
    3  => 31,
    4  => 32,
    5  => 33,
    6  => 34,
    7  => 35,
    8  => 36,
    9  => 37,
    10 => 38,
    11 => 39,
    12 => 40,
    13 => 41,
    14 => 42,
    15 => 43,
    16 => 44,
    17 => 45,
    18 => 46,
    19 => 47,

  --sector 5
    20 => 76,
    21 => 77,
    22 => 78,
    23 => 79,
    24 => 80,
    25 => 81,
    26 => 82,
    27 => 83,
    28 => 84,
    29 => 85,
    30 => 86,
    31 => 87,
    32 => 88,
    33 => 89,
    34 => 90,
    35 => 91,
    36 => 92,
    37 => 93
);

constant SLRAB_OUTPUT_MAP_C : IntegerArray(0 to N_OUTPUT_STREAMS_XLA_SLRAB-1) := (
  --sector 5
    0  => 44,
    1  => 45,
    2  => 46,
    3  => 47
);

begin

  algoRstD1         <= algoRst   when rising_edge(algoClk);
  algoStartSLR12    <= algoStart when rising_edge(algoClk);

  gen_SLR1InputMapping : for i in 0 to N_INPUT_STREAMS_XLA_SLR1-1 generate
    axiStreamInSLR1(i) <= axiStreamIn(SLR1_INPUT_MAP_C(i));
  end generate;

  gen_SLR2InputMapping : for i in 0 to N_INPUT_STREAMS_XLA_SLR2-1 generate
    axiStreamInSLR2(i) <= axiStreamIn(SLR2_INPUT_MAP_C(i));
  end generate;

  gen_SLR1OutputMapping : for i in 0 to N_OUTPUT_STREAMS_XLA_SLR1-1 generate
    axiStreamOut(SLR1_OUTPUT_MAP_C(i)) <= axiStreamOutSLR1(i);
  end generate;

  gen_SLRABOutputMapping : for i in 0 to N_OUTPUT_STREAMS_XLA_SLRAB-1 generate
    axiStreamOut(SLRAB_OUTPUT_MAP_C(i)) <= axiStreamOutSLRAB(i);
  end generate;

  axiStreamInSLRA <= axiStreamFromSLR1;

gen_start_for_SLRABAlgo: process(algoClk)
begin
    IF(rising_edge(algoClk)) THEN
        IF(axiStreamInReg7SLRB(0).tValid = '1' and  axiStreamInSLRA(0).tValid = '1') THEN
            algoStartSLR0   <= '1';
            algoStartD1     <= algoStartSLR0;
            algoStartD2     <= algoStartD1;
            algoStartD3     <= algoStartD2;
            algoStartD4     <= algoStartD3;
        ELSE 
            algoStartD4     <= '0';
        END IF;
    END IF; 
end process;

gen_LinkSync_for_SLRABAlgo: process(algoClk)
begin
    IF(rising_edge(algoClk)) THEN
            axiStreamInReg1SLRB <= axiStreamOutSLR2;
            axiStreamInReg2SLRB <= axiStreamInReg1SLRB;
            axiStreamInReg3SLRB <= axiStreamInReg2SLRB;
            axiStreamInReg4SLRB <= axiStreamInReg3SLRB;
            axiStreamInReg5SLRB <= axiStreamInReg4SLRB;
            axiStreamInReg6SLRB <= axiStreamInReg5SLRB;
            axiStreamInReg7SLRB <= axiStreamInReg6SLRB;
    END IF; 
end process;

  U_RCTAlgoWrapper_SLRA : entity work.RCTAlgoWrapperSLR1
    generic map(
      N_INPUT_STREAMS  => N_INPUT_STREAMS_XLA_SLR1,
      N_OUTPUT_STREAMS => N_OUTPUT_STREAMS_XLA_SLR1
      )
    port map (
      -- Algo Control/Status Signals
      algoClk   => algoClk,
      algoRst   => algoRstD1,
      algoStart => algoStartSLR12,
      algoDone  => open,
      algoIdle  => open,
      algoReady => open,

      axiStreamIn  => axiStreamInSLR1,
      axiStreamOut => axiStreamOutSLR1
      );

  U_RCTAlgoWrapper_SLRB : entity work.RCTAlgoWrapperSLR2
    generic map(
      N_INPUT_STREAMS  => N_INPUT_STREAMS_XLA_SLR2,
      N_OUTPUT_STREAMS => N_OUTPUT_STREAMS_XLA_SLR2
      )
    port map (
      -- Algo Control/Status Signals
      algoClk   => algoClk,
      algoRst   => algoRstD1,
      algoStart => algoStartSLR12,
      algoDone  => open,
      algoIdle  => open,
      algoReady => open,

      axiStreamIn  => axiStreamInSLR2,
      axiStreamOut => axiStreamOutSLR2
      );

  U_RCTAlgoWrapper_SLRAB : entity work.RCTAlgoWrapperSLRAB
    generic map(
      N_INPUT_STREAMS_SLRA  => N_OUTPUT_STREAMS_XLA_SLR1,
      N_INPUT_STREAMS_SLRB  => N_OUTPUT_STREAMS_XLA_SLR2,
      N_OUTPUT_STREAMS      => N_OUTPUT_STREAMS_XLA_SLRAB
      )
    port map (
      -- Algo Control/Status Signals
      algoClk   => algoClk,
      algoRst   => algoRstD1,
      algoStart => algoStartD4,
      algoDone  => open,
      algoIdle  => open,
      algoReady => open,

      axiStreamInSLRA   => axiStreamInSLRA,
      axiStreamInSLRB   => axiStreamInReg7SLRB,
      axiStreamOut      => axiStreamOutSLRAB
      );

end rtl;


