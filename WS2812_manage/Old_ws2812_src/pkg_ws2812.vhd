-------------------------------------------------------------------------------
-- Title      : WS manage package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pkg_ws2812.vhd
-- Author     :   <JorisPC@JORISP>
-- Company    : 
-- Created    : 2019-05-15
-- Last update: 2019-05-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This file is the package of the WS28xx component
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-15  1.0      JorisPC Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_ws2812 is

  -- CONSTANTS
  constant clock_frequency : integer := 50000000;  -- Input clock frequency : 50MHz

  -- WS2812 CONSTANTS ===================================================================================================
  -- WS2812
  -- TH + TL = 1.25 us +- 600 us
  -- T0H : 0.35 us => clock_frequency*0.35*10^6
  -- T0L : 0.8  us => clock_frequency*0.8*10^6
  -- T1H : 0.7  us => clock_frequency*0.7*10^6
  -- T1L : 0.6  us => clock_frequency*0.6*10^6

  -- WS2812 integer constants
  constant T0H : integer := 18;
  constant T0L : integer := 40;
  constant T1H : integer := 35;
  constant T1L : integer := 30;

  -- WS2812b
  -- TH + TL = 1.25 us +- 600 us
  -- T0Hb : 0.4  us => clock_frequency*0.4*10^6
  -- T0Lb : 0.85 us => clock_frequency*0.85*10^6
  -- T1Hb : 0.8  us => clock_frequency*0.8*10^6
  -- T1Lb : 0.45 us => clock_frequency*0.45*10^6

  -- WS2812b integer constants
  constant T0Hb : integer := 20;
  constant T0Lb : integer := 43;
  constant T1Hb : integer := 40;
  constant T1Lb : integer := 23;

  constant max_T : integer := 63;  -- Maximum period : TH + TL for each WS2812

  -- =====================================================================================================================

  -- WS2812_controller constants

  constant C_50us     : unsigned(31 downto 0) := x"000009C4";  -- 50Hz*50us = 2500 => 0x9C4
  constant led_number : integer               := 2;  -- Number of serial leds

  -- TYPES
  type t_led_config_array is array (0 to led_number - 1) of std_logic_vector(23 downto 0);  -- Array for the led configration

  -- COMPONENTS
  component ws2812 is
    generic(T0H : integer := T0H;
            T0L : integer := T0L;
            T1H : integer := T1H;
            T1L : integer := T1L
            );
    port(clock      : in  std_logic;                      -- Input clock
         reset_n    : in  std_logic;                      -- Asynchronous reset
         start      : in  std_logic;                      -- Start a frame
         led_config : in  std_logic_vector(23 downto 0);  -- Led configuration
         frame_done : out std_logic;                      -- Frame terminated
         d_out      : out std_logic                       -- Serial output
         );
  end component;

  component ws2812_controller is
    port (
      clock            : in  std_logic;  -- system clock
      reset_n          : in  std_logic;  -- Asynchronous reset active low
      enable_i         : in  std_logic;  -- Enable of the block
      start_leds_i     : in  std_logic;  -- Start the leds
      leds_config_i    : in  t_led_config_array;  -- Array of leds configuration
      load_config_i    : in  std_logic;  -- Load the new led configuration
      reset_duration_i : in  unsigned(31 downto 0);  -- Duration of the reset between each frames
      d_out            : out std_logic;  -- serial output for the leds configuration
      busy_o           : out std_logic);          -- Controller is busy 
  end component;



  component top_led_cmd is
    port(clock   : in  std_logic;
         reset_n : in  std_logic;
         d_out   : out std_logic);
  end component;

end package pkg_ws2812;
