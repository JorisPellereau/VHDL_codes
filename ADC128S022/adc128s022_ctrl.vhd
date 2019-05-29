-------------------------------------------------------------------------------
-- Title      : ADC128s022 Controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc128s022_ctrl.vhd
-- Author     :   <JorisPC@JORISP>
-- Company    : 
-- Created    : 2019-05-29
-- Last update: 2019-05-29
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This is the controller for the ADC128S022 component
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-29  1.0      JorisPC Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity adc128s022_ctrl is

  port (
    clock       : in  std_logic;        -- Input system clock
    reset_n     : in  std_logic;        -- Active low asynchronous reset
    adc_sdat    : in  std_logic;        -- ADC serial data
    channel_sel : in  std_logic_vector(2 downto 0);   -- ADC channel selector
    conv_mode   : in  std_logic_vector(1 downto 0);   -- Conversion mode
    en          : in  std_logic;        -- Enable - Start conversion
    adc_cs_n    : out std_logic;        -- ADC Chip select
    adc_sclk    : out std_logic;        -- ADC Serial Clock
    adc_saddr   : out std_logic;        -- ADC d_in controller
    adc_data    : out std_logic_vector(11 downto 0);  -- ADC data
    adc_channel : out std_logic_vector(2 downto 0);   -- Current ADC channel
    data_valid  : out std_logic);       -- Data and Current channel available

end entity adc128s022_ctrl;



architecture arch_adc128s022_ctrl of adc128s022_ctrl is

  -- CONSTANTS
  constant C_max_T  : integer := 50;    -- Max counter for the SCLK generation
  constant C_half_T : integer := C_max_T/2;  -- Half T of sclk

  -- SIGNALS
  signal run_conv  : std_logic;         -- Run the conversion when = '1'
  signal stop_conv : std_logic;         -- Stop the conversion

  signal cnt_sclk : integer range 0 to C_max_T;  -- Counts from 0 to 50
  signal cnt_16   : integer range 0 to 16;       -- Counts 16 bits

  signal adc_cs_n_s : std_logic;        -- Chip select signal
  signal adc_sclk_s : std_logic;        -- ADC SCLK signal

  -- Rising edge and falling edge detect
  signal adc_sclk_old_s : std_logic;    -- Old adc_sclk_s
  signal adc_sclk_re_s  : std_logic;    -- RE of adc_sclk
  signal adc_sclk_fe_s  : std_logic;    -- FE of adc sclk

begin


  -- purpose: This process manages the Chip Select output
  p_cs_mng : process (clock, reset_n)
  begin  -- process p_cs_mng
    if reset_n = '0' then                   -- asynchronous reset (active low)
      adc_cs_n_s <= '1';                    -- Set to '1' on reset
      run_conv   <= '0';
      stop_conv  <= '0';
    elsif clock'event and clock = '1' then  -- rising clock edge
      if(en = '1') then
        adc_cs_n_s <= '0';
        run_conv   <= '1';
        stop_conv  <= '0';
      elsif(en = '0' and cnt_16 = 16) then
        adc_cs_n_s <= '1';
        stop_conv  <= '1';
        run_conv   <= '0';
      end if;
    end if;
  end process p_cs_mng;

  adc_cs_n <= adc_cs_n_s;               -- Output connection



  -- purpose: This process manages the SCLK output
  p_sclk_mng : process (clock, reset_n)
  begin  -- process p_sclk_mng
    if reset_n = '0' then                   -- asynchronous reset (active low)
      cnt_sclk   <= 0;
      adc_sclk_s <= '1';
    elsif clock'event and clock = '1' then  -- rising clock edge
      if(stop_conv = '1') then
        cnt_sclk   <= 0;
        adc_sclk_s <= '1';
      else
        if(run_conv = '1') then
          if(cnt_sclk = C_half_T) then
            adc_sclk_s <= not adc_sclk_s;
            cnt_sclk   <= 0;
          else
            cnt_sclk <= cnt_sclk + 1;
          end if;
        end if;
      end if;

    end if;
  end process p_sclk_mng;

  adc_sclk <= adc_sclk_s;


  -- purpose: This process detects the RE and FE of sclk 
  p_sclk_re_fe_detect : process (clock, reset_n)
  begin  -- process p_sclk_re_fe_detect
    if reset_n = '0' then                   -- asynchronous reset (active low)
      adc_sclk_old_s <= '0';
    elsif clock'event and clock = '1' then  -- rising clock edge
      adc_sclk_old_s <= adc_sclk_s;
    end if;
  end process p_sclk_re_fe_detect;
  adc_sclk_re_s <= adc_sclk_s and not adc_sclk_old_s;
  adc_sclk_fe_s <= not adc_sclk_s and adc_sclk_old_s;


  -- purpose: This process counts the bit to transmit
  p_cnt16_mng : process (clock, reset_n)
  begin  -- process p_cnt16_ng
    if reset_n = '0' then                   -- asynchronous reset (active low)
      cnt_16 <= 0;
    elsif clock'event and clock = '1' then  -- rising clock edge
      if(stop_conv = '1') then
        cnt_16 <= 0;
      else
        if(adc_sclk_re_s = '1') then
          if(cnt_16 = 16) then
            cnt_16 <= 1;
          else
            cnt_16 <= cnt_16 + 1;
          end if;
        end if;
      end if;
    end if;
  end process p_cnt16_mng;

end architecture arch_adc128s022_ctrl;