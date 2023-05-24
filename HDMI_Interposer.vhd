--  Copy the following two statements and paste them before the
--  Entity declaration, unless they already exist.

Library UNISIM;
use UNISIM.vcomponents.all;

--  <-----Cut code below this line and paste into the architecture body---->

   -- IBUFDS: Differential Input Buffer
   --         Artix-7
   -- Xilinx HDL Language Template, version 2022.2

   IBUFDS_inst : IBUFDS
   generic map (
      DIFF_TERM => FALSE, -- Differential Termination 
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => O,  -- Buffer output
      I => I,  -- Diff_p buffer input (connect directly to top-level port)
      IB => IB -- Diff_n buffer input (connect directly to top-level port)
   );

   -- End of IBUFDS_inst instantiation

					--  Copy the following two statements and paste them before the
--  Entity declaration, unless they already exist.

Library UNISIM;
use UNISIM.vcomponents.all;

--  <-----Cut code below this line and paste into the architecture body---->

   -- OBUFDS: Differential Output Buffer
   --         Artix-7
   -- Xilinx HDL Language Template, version 2022.2
   
   OBUFDS_inst : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
      SLEW => "SLOW")          -- Specify the output slew rate
   port map (
      O => O,     -- Diff_p output (connect directly to top-level port)
      OB => OB,   -- Diff_n output (connect directly to top-level port)
      I => I      -- Buffer input 
   );
  
   -- End of OBUFDS_inst instantiation

					

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee.math_real.all;

entity HDMI_Interposer is
    port (
        
    );
end HDMI_Interposer;

architecture behaviour of HDMI_Interposer is
    component TMDS_8b10b_encoder is 
        port (
            i_clk           : in std_logic;
            i_data_enable   : in std_logic;
            i_C0            : in std_logic;
            i_C1            : in std_logic;
            i_data          : in std_logic_vector(7 downto 0);
            o_data          : out std_logic_vector(9 downto 0)
        );
    end component;

    component TMDS_decoder is 
        port (
            i_data          : in std_logic_vector(9 downto 0);
            o_data          : out std_logic_vector(7 downto 0);
            o_data_enable   : out std_logic;
            o_C0            : out std_logic;
            o_C1            : out std_logic;
            i_clk           : in std_logic
        );
    end component;

    signal w_data_link  : std_logic_vector(9 downto 0);


begin

    
end architecture;
    