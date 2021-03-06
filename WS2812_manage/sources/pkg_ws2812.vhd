-------------------------------------------------------------------------------
-- Title      : WS manage package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pkg_ws2812.vhd
-- Author     :   <JorisPC@JORISP>
-- Company    : 
-- Created    : 2019-05-15
-- Last update: 2019-11-24
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

  -- CONSTANTS
  constant C_MAX_LEDS : integer := 10;  -- Number Max of leds



  -- WS2812_controller constants

  constant C_50us   : unsigned(31 downto 0) := x"000009C4";  -- 50Hz*50us = 2500 => 0x9C4
  constant C_LED_NB : integer               := 8;  -- Number of serial leds

  -- TYPES
  type t_led_config_array is array (0 to C_LED_NB - 1) of std_logic_vector(23 downto 0);  -- Array for the led configration


  -- Config LEDS CONSTANTS

  constant C_DEFAULT_LEDS   : t_led_config_array := (others => x"111111");
  constant C_ALL_GREEN_LEDS : t_led_config_array := (others => x"FF0000");
  constant C_ALL_RED_LEDS   : t_led_config_array := (others => x"00FF00");
  constant C_ALL_BLUE_LEDS  : t_led_config_array := (others => x"0000FF");
  constant C_TEST_LEDS_1 : t_led_config_array := (0 => x"3633FF",
                                                  1 => x"4AEB08",
                                                  2 => x"896838",
                                                  3 => x"E70B65",
                                                  4 => x"10EA9B",
                                                  5 => x"EDE905",
                                                  6 => x"36DB9C",
                                                  7 => x"000000");

  constant C_TEST_LEDS_2 : t_led_config_array := (0 => x"AA00DC",
                                                  1 => x"B324DC",
                                                  2 => x"BF57DE",
                                                  3 => x"C876DF",
                                                  4 => x"CF9ADF",
                                                  5 => x"D8B8E2",
                                                  6 => x"DBCBDF",
                                                  7 => x"E3E3E3");

  constant C_TEST_LEDS_3 : t_led_config_array := (0 => x"154360",
                                                  1 => x"1A5276",
                                                  2 => x"1F618D",
                                                  3 => x"2471A3",
                                                  4 => x"1960B9",
                                                  5 => x"5499C7",
                                                  6 => x"7FB3D5",
                                                  7 => x"A9CCE3");

  constant C_TEST_LEDS_4 : t_led_config_array := (0 => x"431460",
                                                  1 => x"521A76",
                                                  2 => x"611A8D",
                                                  3 => x"7124A3",
                                                  4 => x"6019B9",
                                                  5 => x"9954C7",
                                                  6 => x"B37FD5",
                                                  7 => x"CCA9E3");

  constant C_TEST_LEDS_DYN : t_led_config_array := (0 => x"FF0000",
                                                    1 => x"00FF00",
                                                    2 => x"0000FF",
                                                    3 => x"d4ff00",
                                                    4 => x"ff00e4",
                                                    5 => x"ff8b00",
                                                    6 => x"00ffe8",
                                                    7 => x"6b00a4");

  constant C_TEST_LEDS_DYN_2 : t_led_config_array := (0 => x"FFFF00",
                                                      1 => x"FFFF00",
                                                      2 => x"FFFF00",
                                                      3 => x"FFFF00",
                                                      4 => x"FFFF00",
                                                      5 => x"FFFF00",
                                                      6 => x"FFFF00",
                                                      7 => x"64E6A7");



  -- COMPONENTS
  component ws2812 is
    generic(T0H : integer := T0H;
            T0L : integer := T0L;
            T1H : integer := T1H;
            T1L : integer := T1L
            );
    port(clock_i      : in  std_logic;  -- Input clock
         reset_n      : in  std_logic;  -- Asynchronous reset
         start_i      : in  std_logic;  -- Start a frame
         led_config_i : in  std_logic_vector(23 downto 0);  -- Led configuration
         frame_done_o : out std_logic;  -- Frame terminated
         d_out_o      : out std_logic   -- Serial output
         );
  end component;




  component ws2812_mngt is

    generic (
      G_LED_NUMBER : integer range 1 to C_MAX_LEDS := C_LED_NB);

    port (
      clock_i             : in  std_logic;  -- System Clock
      reset_n             : in  std_logic;  -- Active low asynchronous Reset
      start_leds_i        : in  std_logic;  -- Start led
      frame_ws2812_done_i : in  std_logic;  -- Frame from WS2812 done
      led_config_array_i  : in  t_led_config_array;  -- Config of the leds
      start_ws2812_o      : out std_logic;  -- Start the frame
      led_config_o        : out std_logic_vector(23 downto 0);
      config_done_o       : out std_logic);          -- config terminated

  end component;



  component ws2812_rst_mng is

    port (
      clock_i       : in  std_logic;    -- System clock
      reset_n       : in  std_logic;    -- Asychronous active low reset
      en_start_i    : in  std_logic;    -- Enable the frame generation
      reset_gen_i   : in  std_logic;    -- Command for the reset genration
      config_done_i : in  std_logic;    -- Config done from the WS2812_mngt
      start_leds_o  : out std_logic);   -- Start config, to the WS2812 MNGT
  end component;


  component config_leds is

    generic (
      G_LED_NUMBER : integer range 1 to C_MAX_LEDS := C_LED_NB);  -- Numer of leds

    port (
      clock_i        : in  std_logic;   -- System Clock
      reset_n        : in  std_logic;   -- Active low asynchronous reset
      sel_config_i   : in  std_logic_vector(7 downto 0);  -- Config led selection
      config_led_o   : out t_led_config_array;  -- Current leds config
      config_valid_o : out std_logic);  -- Current conf. Valid

  end component;


  component ws2812_ctrl is

    generic (
      G_LED_NUMBER : integer range 1 to C_MAX_LEDS := C_LED_NB);

    port (
      clock_i           : in  std_logic;   -- System Clock
      reset_n           : in  std_logic;   -- Active Low asynchronous reset
      sel_config_i      : in  std_logic_vector(7 downto 0);  -- Sel config leds
      ws2812_leds_cmd_i : in  std_logic_vector(7 downto 0);  -- reg command
      ws2812_data_o     : out std_logic);  -- PWM data to the WS2812 component

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


  component ws2812_leds_mngt is

    generic (
      G_LEDS_NB  : integer := 8;        -- Leds number;
      G_CNT_SIZE : integer := 16);      -- Refresh cnt size
    port (
      clock              : in  std_logic;   -- Clock
      rst_n              : in  std_logic;   -- Active low asynchronous reset
      i_stat_dyn         : in  std_logic;   -- Static or dynamique config
      i_leds_conf_update : in  std_logic;   -- Update the leds configuration
      i_leds_config      : in  t_led_config_array;             -- Leds Colors
      i_en               : in  std_logic;   -- Block enable
      i_frame_done       : in  std_logic;   -- Frame done from WS2812 block
      i_max_cnt          : in  std_logic_vector(G_CNT_SIZE - 1 downto 0);  -- Max cnt for the refresh
      o_led_config       : out std_logic_vector(23 downto 0);  -- Current leds config
      o_stat_conf_done   : out std_logic;   -- Static conf. done
      o_dyn_ongoing      : out std_logic;   -- Dyn config ongoing
      o_cfg_dyn_done     : out std_logic;   -- Config. Dyn done
      o_rfrsh_dyn_done   : out std_logic;   -- Refresh Dyn done
      o_start_frame      : out std_logic);  -- Start a WS2812 frame
  end component;

  component ws2812_leds_ctrl is

    generic (
      G_LEDS_NB          : integer := 8;     -- Leds numbers
      G_REFRESH_CNT_SIZE : integer := 16);   -- REFRESH CNT Size
    port (
      clock               : in  std_logic;   -- Clock
      rst_n               : in  std_logic;   -- Active low asynchronous reset
      i_en                : in  std_logic;   -- Block enable
      i_stat_dyn          : in  std_logic;   -- Static/Dyn. config
      i_leds_conf_update  : in  std_logic;   -- Start/update the conf
      i_rfrsf_value_valid : in  std_logic;   -- Refresh value valid
      i_rfrsf_value       : in  std_logic_vector(G_REFRESH_CNT_SIZE - 1 downto 0);
      o_d_out             : out std_logic);  -- WS2812 Output
  end component;

  component ws2812_registers_mngt is

    generic (
      G_REG_SIZE : integer := 8;        -- Registers Size
      G_CNT_SIZE : integer := 16);      -- Counter size 
    port (
      clock               : in  std_logic;  -- Clock
      rst_n               : in  std_logic;  -- Asynchronous reset
      i_stat_dyn          : in  std_logic;  -- Static-Dyn. command
      i_leds_conf_update  : in  std_logic;  -- Upadate config. Leds
      i_dyn_ongoing       : in  std_logic;  -- Dynamic mode ongoing
      i_rfrsh_dyn_done    : in  std_logic;  -- Dyn. Refresh done
      i_rfrsh_value_valid : in  std_logic;  -- Rfresh value valid
      i_rfrsh_value       : in  std_logic_vector(G_CNT_SIZE - 1 downto 0);  -- Refresh in
      o_rfrsh_value       : out std_logic_vector(G_CNT_SIZE - 1 downto 0);  -- Refresh out
      o_status            : out std_logic_vector(G_REG_SIZE - 1 downto 0)  -- Status reg
      );
  end component;

end package pkg_ws2812;
