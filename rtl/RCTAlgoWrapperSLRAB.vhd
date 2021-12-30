library IEEE;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;


entity RCTAlgoWrapperSLRAB is
  generic (
    N_INPUT_STREAMS_SLRA  : integer := 2;
    N_INPUT_STREAMS_SLRB  : integer := 6;
    N_OUTPUT_STREAMS : integer := 4
    );
  port (
    -- Algo Control/Status Signals
    algoClk   : in  std_logic;
    algoRst   : in  std_logic;
    algoStart : in  std_logic;
    algoDone  : out std_logic := '0';
    algoIdle  : out std_logic := '0';
    algoReady : out std_logic := '0';

    -- AXI-Stream In/Out Ports

    axiStreamInSLRA  : in  AxiStreamMasterArray(0 TO N_INPUT_STREAMS_SLRA-1);
    axiStreamInSLRB  : in  AxiStreamMasterArray(0 TO N_INPUT_STREAMS_SLRB-1);
    axiStreamOut     : out AxiStreamMasterArray(0 TO N_OUTPUT_STREAMS-1)
    );

end RCTAlgoWrapperSLRAB;

architecture Behavioral of RCTAlgoWrapperSLRAB is

  signal algoRstD1, algoRstD1n : std_logic;
  signal algoStartD1 : std_logic;
  attribute max_fanout                           : integer;
  attribute max_fanout of algoRstD1, algoStartD1 : signal is 1;

  component algo_top_SLRAB is
    port (
        ap_clk              : IN STD_LOGIC;
        ap_rst              : IN STD_LOGIC;
        ap_start            : IN STD_LOGIC;
        ap_done             : OUT STD_LOGIC;
        ap_idle             : OUT STD_LOGIC;
        ap_ready            : OUT STD_LOGIC;

        link_inSLRA_0_V     : IN STD_LOGIC_VECTOR (383 downto 0);
        link_inSLRA_1_V     : IN STD_LOGIC_VECTOR (383 downto 0);

        link_inSLRB_0_V     : IN STD_LOGIC_VECTOR (383 downto 0);
        link_inSLRB_1_V     : IN STD_LOGIC_VECTOR (383 downto 0);
        link_inSLRB_2_V     : IN STD_LOGIC_VECTOR (383 downto 0);
        link_inSLRB_3_V     : IN STD_LOGIC_VECTOR (383 downto 0);
        link_inSLRB_4_V     : IN STD_LOGIC_VECTOR (383 downto 0);
        link_inSLRB_5_V     : IN STD_LOGIC_VECTOR (383 downto 0);

        link_out_0_V        : OUT STD_LOGIC_VECTOR (383 downto 0);
        link_out_1_V        : OUT STD_LOGIC_VECTOR (383 downto 0);
        link_out_2_V        : OUT STD_LOGIC_VECTOR (383 downto 0);
        link_out_3_V        : OUT STD_LOGIC_VECTOR (383 downto 0);

        link_out_0_V_ap_vld : OUT STD_LOGIC;
        link_out_1_V_ap_vld : OUT STD_LOGIC;
        link_out_2_V_ap_vld : OUT STD_LOGIC;
        link_out_3_V_ap_vld : OUT STD_LOGIC
        );

  end component;

  type t_cyc_6_arr is array(integer range <>) of integer range 0 to 5;
  type t_slv_384_arr is array(integer range <>) of std_logic_vector(383 downto 0);

  signal link_in_SLRA               : t_slv_384_arr(0 TO N_INPUT_STREAMS_SLRA-1);
  signal link_in_reg_SLRA           : t_slv_384_arr(0 TO N_INPUT_STREAMS_SLRA-1);

  signal link_in_SLRB               : t_slv_384_arr(0 TO N_INPUT_STREAMS_SLRB-1);
  signal link_in_reg_SLRB           : t_slv_384_arr(0 TO N_INPUT_STREAMS_SLRB-1);

  signal link_out                   : t_slv_384_arr(0 TO N_OUTPUT_STREAMS-1);
  signal link_out_reg               : t_slv_384_arr(0 TO N_OUTPUT_STREAMS-1);

  signal link_out_ap_vld            : std_logic_vector(0 TO N_OUTPUT_STREAMS-1) := (others => '0');
  signal link_out_ap_vld_latched    : std_logic_vector(0 TO N_OUTPUT_STREAMS-1) := (others => '0');

  signal in_cyc_SLRA                : t_cyc_6_arr(0 TO N_INPUT_STREAMS_SLRA-1);
  signal in_cyc_SLRB                : t_cyc_6_arr(0 TO N_INPUT_STREAMS_SLRB-1);
  signal out_cyc                    : t_cyc_6_arr(0 To N_OUTPUT_STREAMS-1);
begin

  algoRstD1 <= algoRst      when rising_edge(algoClk);
  --algoRstD1n  <= not algoRstD1;
  algoStartD1 <= algoStart  when rising_edge(algoClk);

  gen_cyc_in_SLRA : for idx in 0 TO N_INPUT_STREAMS_SLRA-1 generate
    process(algoClk) is
    begin
      if rising_edge(algoClk) then
        if (axiStreamInSLRA(idx).tValid = '0') then
          in_cyc_SLRA(idx) <= 0;
        elsif (axiStreamInSLRA(idx).tValid = '1') then
          in_cyc_SLRA(idx) <= in_cyc_SLRA(idx) + 1;
          if (in_cyc_SLRA(idx) = 5) then
            in_cyc_SLRA(idx) <= 0;
          end if;
        end if;

        if (in_cyc_SLRA(idx) = 0 and axiStreamInSLRA(idx).tValid = '1') then
            link_in_SLRA(idx)(63 downto 0)  <= axiStreamInSLRA(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRA(idx) = 1 and axiStreamInSLRA(idx).tValid = '1') then
            link_in_SLRA(idx)(127 downto 64)  <= axiStreamInSLRA(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRA(idx) = 2 and axiStreamInSLRA(idx).tValid = '1') then
            link_in_SLRA(idx)(191 downto 128)  <= axiStreamInSLRA(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRA(idx) = 3 and axiStreamInSLRA(idx).tValid = '1') then
            link_in_SLRA(idx)(255 downto 192)  <= axiStreamInSLRA(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRA(idx) = 4 and axiStreamInSLRA(idx).tValid = '1') then
            link_in_SLRA(idx)(319 downto 256)  <= axiStreamInSLRA(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRA(idx) = 5 and axiStreamInSLRA(idx).tValid = '1') then
            link_in_reg_SLRA(idx)(63 downto 0)    <= link_in_SLRA(idx)(63 downto 0);
            link_in_reg_SLRA(idx)(127 downto 64)  <= link_in_SLRA(idx)(127 downto 64);
            link_in_reg_SLRA(idx)(191 downto 128) <= link_in_SLRA(idx)(191 downto 128);
            link_in_reg_SLRA(idx)(255 downto 192) <= link_in_SLRA(idx)(255 downto 192);
            link_in_reg_SLRA(idx)(319 downto 256) <= link_in_SLRA(idx)(319 downto 256);
            link_in_reg_SLRA(idx)(383 downto 320) <= axiStreamInSLRA(idx).tdata(63 downto 0);
        end if;
      end if;
    end process;
  end generate;

  gen_cyc_in_SLRB : for idx in 0 TO N_INPUT_STREAMS_SLRB-1 generate
    process(algoClk) is
    begin
      if rising_edge(algoClk) then
        if (axiStreamInSLRB(idx).tValid = '0') then
            in_cyc_SLRB(idx) <= 0;
        elsif (axiStreamInSLRB(idx).tValid = '1') then
            in_cyc_SLRB(idx) <= in_cyc_SLRB(idx) + 1;
        if (in_cyc_SLRB(idx) = 5) then
            in_cyc_SLRB(idx) <= 0;
            end if;
        end if;
        if (in_cyc_SLRB(idx) = 0 and axiStreamInSLRB(idx).tValid = '1') then
            link_in_SLRB(idx)(63 downto 0)  <= axiStreamInSLRB(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRB(idx) = 1 and axiStreamInSLRB(idx).tValid = '1') then
            link_in_SLRB(idx)(127 downto 64)  <= axiStreamInSLRB(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRB(idx) = 2 and axiStreamInSLRB(idx).tValid = '1') then
            link_in_SLRB(idx)(191 downto 128)  <= axiStreamInSLRB(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRB(idx) = 3 and axiStreamInSLRB(idx).tValid = '1') then
            link_in_SLRB(idx)(255 downto 192)  <= axiStreamInSLRB(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRB(idx) = 4 and axiStreamInSLRB(idx).tValid = '1') then
            link_in_SLRB(idx)(319 downto 256)  <= axiStreamInSLRB(idx).tdata(63 downto 0);
        end if;
        if (in_cyc_SLRB(idx) = 5 and axiStreamInSLRB(idx).tValid = '1') then
            link_in_reg_SLRB(idx)(63 downto 0)    <= link_in_SLRB(idx)(63 downto 0);
            link_in_reg_SLRB(idx)(127 downto 64)  <= link_in_SLRB(idx)(127 downto 64);
            link_in_reg_SLRB(idx)(191 downto 128) <= link_in_SLRB(idx)(191 downto 128);
            link_in_reg_SLRB(idx)(255 downto 192) <= link_in_SLRB(idx)(255 downto 192);
            link_in_reg_SLRB(idx)(319 downto 256) <= link_in_SLRB(idx)(319 downto 256);
            link_in_reg_SLRB(idx)(383 downto 320) <= axiStreamInSLRB(idx).tdata(63 downto 0);
        end if;
      end if;
    end process;
  end generate;

  gen_cyc_out : for idx in 0 TO N_OUTPUT_STREAMS-1 generate
    process(algoClk) is
    begin
      if rising_edge(algoClk) then
        if (link_out_ap_vld(idx) = '1') then
          link_out_reg(idx) <= link_out(idx);
        end if;
        if (algoRstD1 = '1') then
            link_out_ap_vld_latched(idx) <= '0';
        elsif (link_out_ap_vld(idx) = '1') then
            link_out_ap_vld_latched(idx) <= '1';
        end if;

        if (link_out_ap_vld_latched(idx) = '0') then
          out_cyc(idx)                <= 0;
          axiStreamOut(idx).tvalid <= '0';
        else
          axiStreamOut(idx).tvalid <= '1';
          out_cyc(idx)                <= out_cyc(idx) + 1;
          if (out_cyc(idx) = 5) then
            out_cyc(idx) <= 0;
          end if;
        end if;

        if (out_cyc(idx) = 0) then axiStreamOut(idx).tdata(63 downto 0) <= link_out_reg(idx)(63 downto 0);      end if;
        if (out_cyc(idx) = 1) then axiStreamOut(idx).tdata(63 downto 0) <= link_out_reg(idx)(127 downto 64);    end if;
        if (out_cyc(idx) = 2) then axiStreamOut(idx).tdata(63 downto 0) <= link_out_reg(idx)(191 downto 128);   end if;
        if (out_cyc(idx) = 3) then axiStreamOut(idx).tdata(63 downto 0) <= link_out_reg(idx)(255 downto 192);   end if;
        if (out_cyc(idx) = 4) then axiStreamOut(idx).tdata(63 downto 0) <= link_out_reg(idx)(319 downto 256);   end if;
        if (out_cyc(idx) = 5) then axiStreamOut(idx).tdata(63 downto 0) <= link_out_reg(idx)(383 downto 320);   end if;

      end if;
    end process;
  end generate;

  i_algo_top_SLRAB : algo_top_SLRAB
    port map (
        ap_clk              => algoClk,
        ap_rst              => algoRstD1,
        ap_start            => algoStartD1,
        ap_done             => algoDone,
        ap_idle             => algoIdle,
        ap_ready            => algoReady,

        link_inSLRA_0_V     => link_in_reg_SLRA(0),
        link_inSLRA_1_V     => link_in_reg_SLRA(1),

        link_inSLRB_0_V     => link_in_reg_SLRB(0),
        link_inSLRB_1_V     => link_in_reg_SLRB(1),
        link_inSLRB_2_V     => link_in_reg_SLRB(2),
        link_inSLRB_3_V     => link_in_reg_SLRB(3),
        link_inSLRB_4_V     => link_in_reg_SLRB(4),
        link_inSLRB_5_V     => link_in_reg_SLRB(5),

        link_out_0_V        => link_out(0),
        link_out_1_V        => link_out(1),
        link_out_2_V        => link_out(2),
        link_out_3_V        => link_out(3),

        link_out_0_V_ap_vld => link_out_ap_vld(0),
        link_out_1_V_ap_vld => link_out_ap_vld(1),
        link_out_2_V_ap_vld => link_out_ap_vld(2),
        link_out_3_V_ap_vld => link_out_ap_vld(3)
);

end Behavioral;

