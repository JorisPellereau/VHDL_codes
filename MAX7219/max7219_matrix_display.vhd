-------------------------------------------------------------------------------
-- Title      : MAX7219 MATRIX DISPLAY TOP BLOCK
-- Project    : 
-------------------------------------------------------------------------------
-- File       : max7219_matrix_display.vhd
-- Author     :   <JorisP@DESKTOP-LO58CMN>
-- Company    : 
-- Created    : 2020-05-03
-- Last update: 2020-05-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: MAX7219 MATRIX DISPLAY TOP BLOCK
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-05-03  1.0      JorisP  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library lib_max7219;
use lib_max7219.pkg_max7219.all;

entity max7219_matrix_display is
  generic (
    G_DIGITS_NB                  : integer range 2 to 8;  -- DIGIT NB on THE MATRIX DISPLAY
    G_DATA_WIDTH                 : integer                       := 32;  -- INPUTS SCORE WIDTH
    G_RAM_ADDR_WIDTH             : integer                       := 8;  -- RAM ADDR WIDTH
    G_RAM_DATA_WIDTH             : integer                       := 16;  -- RAM DATA WIDTH
    G_DECOD_MAX_CNT_32B          : std_logic_vector(31 downto 0) := x"02FAF080";
    G_MAX7219_IF_MAX_HALF_PERIOD : integer                       := 50;  -- MAX HALF PERIOD for MAX729 CLK generation
    G_MAX7219_LOAD_DUR           : integer                       := 4);  -- MAX7219 LOAD duration in period of clk
  port (
    clk            : in  std_logic;     -- Clock
    rst_n          : in  std_logic;     -- Asynchronous Reset
    i_score        : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);  -- Score to Display
    i_score_val    : in  std_logic;     -- Scare Valid
    o_max7219_load : out std_logic;     -- MAX7219 LOAD
    o_max7219_data : out std_logic;     -- MAX7219 DATA
    o_max7219_clk  : out std_logic      -- MAX729 CLK
    );

end entity max7219_matrix_display;

architecture behv of max7219_matrix_display is

  -- COMPONENTS
  component digits_decod_shift is
    generic (
      G_DIGITS_NB  : integer range 2 to 8 := 8;    -- DIGITS Number to decod
      G_DATA_WIDTH : integer              := 32);  -- DATA WIDTH

    port (
      clk          : in  std_logic;     -- Clock
      rst_n        : in  std_logic;     -- Asynchronous Reset
      i_data2decod : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);  -- Data to decod
      i_val        : in  std_logic;     -- Input valid
      o_decod      : out std_logic_vector(G_DIGITS_NB*4 - 1 downto 0);  -- Decod output
      o_done       : out std_logic);    -- Decod Done
  end component digits_decod_shift;

  -- INTERNAL SIGNALS
  signal s_max7219_load : std_logic;
  signal s_max7219_clk  : std_logic;
  signal s_max7219_data : std_logic;

  signal s_me    : std_logic;
  signal s_we    : std_logic;
  signal s_addr  : std_logic_vector(7 downto 0);
  signal s_wdata : std_logic_vector(15 downto 0);
  signal s_rdata : std_logic_vector(15 downto 0);
  signal s_en    : std_logic;

  signal s_start_ptr    : std_logic_vector(7 downto 0);
  signal s_last_ptr     : std_logic_vector(7 downto 0);
  signal s_ptr_val      : std_logic;
  signal s_loop         : std_logic;
  signal s_ptr_equality : std_logic;

  signal s_score_decod     : std_logic_vector(G_DIGITS_NB*4 - 1 downto 0);
  signal s_score_decod_val : std_logic;

  signal s_score_cmd : t_score_array;
  signal s_score_val : std_logic;
  
begin  -- architecture behv

  -- DIGITS DECOD SHIFT
  digits_decod_shift_inst_0 : digits_decod_shift
    generic map (
      G_DIGITS_NB  => G_DIGITS_NB,
      G_DATA_WIDTH => G_DATA_WIDTH)
    port map(
      clk          => clk,
      rst_n        => rst_n,
      i_data2decod => i_score,
      i_val        => i_score_val,
      o_decod      => s_score_decod,
      o_done       => s_score_decod_val
      );


  -- COMMAND ORGANIZER INST
  max7219_cmd_organizer_inst_0 : max7219_cmd_organizer
    generic map(
      G_RAM_DATA_WIDTH => G_RAM_DATA_WIDTH,
      G_DIGITS_NB      => G_DIGITS_NB)
    port map(
      clk               => clk,
      rst_n             => rst_n,
      i_score_decod     => s_score_decod,
      i_score_decod_val => s_score_decod_val,
      o_score_cmd       => s_score_cmd,
      o_score_val       => s_score_val
      );


  -- MAX7219 CMD DECOD INST
  max7219_cmd_decod_inst_0 : max7219_cmd_decod
    generic map (
      G_RAM_ADDR_WIDTH             => G_RAM_ADDR_WIDTH,
      G_RAM_DATA_WIDTH             => G_RAM_DATA_WIDTH,
      G_MAX7219_IF_MAX_HALF_PERIOD => G_MAX7219_IF_MAX_HALF_PERIOD,
      G_MAX7219_LOAD_DUR           => G_MAX7219_LOAD_DUR)
    port map (
      clk   => clk,
      rst_n => rst_n,
      i_en  => s_en,

      -- RAM I/F
      i_me    => s_me,
      i_we    => s_we,
      i_addr  => s_addr,
      i_wdata => s_wdata,
      o_rdata => s_rdata,

      -- RAM INFO.
      i_start_ptr    => s_start_ptr,
      i_last_ptr     => s_last_ptr,
      i_ptr_val      => s_ptr_val,
      i_loop         => s_loop,
      o_ptr_equality => s_ptr_equality,

      -- MAX7219 I/F
      o_max7219_load => s_max7219_load,
      o_max7219_data => s_max7219_data,
      o_max7219_clk  => s_max7219_clk);  -- MAX7219 CLK


  -- OUTPUTS affectations
  o_max7219_clk  <= s_max7219_clk;
  o_max7219_data <= s_max7219_data;
  o_max7219_load <= s_max7219_load;

end architecture behv;
