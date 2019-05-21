-------------------------------------------------------------------------------
-- Title      : Test of the WS2812
-- Project    : 
-------------------------------------------------------------------------------
-- File       : test_WS2812.vhd
-- Author     :   <JorisPC@JORISP>
-- Company    : 
-- Created    : 2019-05-16
-- Last update: 2019-05-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This is the unitary test of the WS2812
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-16  1.0      JorisPC Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_ws2812;
use lib_ws2812.pkg_ws2812.all;

entity test_WS2812 is
end test_WS2812;

architecture arch_test_WS2812 of test_WS2812 is

  constant T_clk     : time := 20 ns/2.0;  -- 50 MHz
  constant t_reset_n : time := 100 ns;

  signal clock   : std_logic := '0';
  signal reset_n : std_logic := '0';

  -- Instance 1
  signal start      : std_logic := '0';
  signal led_config : std_logic_vector(23 downto 0);
  signal frame_done : std_logic;
  signal d_out      : std_logic;

  -- Instance 2
  signal start_2      : std_logic := '0';
  signal led_config_2 : std_logic_vector(23 downto 0);
  signal frame_done_2 : std_logic;
  signal d_out_2      : std_logic;

begin



  clock <= not clock after T_clk;       -- Generation de clock

  simu_p : process
  begin

    led_config   <= (others => '0');
    led_config_2 <= (others => '0');
    reset_n      <= '0', '1' after t_reset_n;  -- Reset_n
    for i in 1000 to 1005 loop
      wait for 100*t_reset_n;  -- to_integer(unsigned(reset_duration))*t_reset_n;  --100*t_reset_n;
      led_config   <= std_logic_vector(to_unsigned(i, led_config'length));
      led_config_2 <= std_logic_vector(to_unsigned(i, led_config_2'length));
      start        <= '1', '0' after 100 ns;
      wait until rising_edge(frame_done);
    end loop;

    assert false report "end of simu !!!" severity failure;

    wait;
  end process;


  -- Instance 1
  WS2812_1 : WS2812
    generic map(T0H => T0H,
                T0L => T0L,
                T1H => T1H,
                T1L => T1L)
    port map (clock      => clock,
              reset_n    => reset_n,
              start      => start,
              led_config => led_config,
              frame_done => frame_done,
              d_out      => d_out);


  -- Instance 2
  WS2812_mng_inst_2 : WS2812_mng_2
    generic map(T0H => T0H,
                T0L => T0L,
                T1H => T1H,
                T1L => T1L)
    port map (clock      => clock,
              reset_n    => reset_n,
              start      => start,
              led_config => led_config_2,
              frame_done => frame_done_2,
              d_out      => d_out_2);

end arch_test_WS2812;
