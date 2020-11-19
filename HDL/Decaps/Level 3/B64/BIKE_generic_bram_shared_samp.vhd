----------------------------------------------------------------------------------
-- COPYRIGHT (c) 2020 ALL RIGHT RESERVED
--
-- COMPANY:					Ruhr-University Bochum, Chair for Security Engineering
-- AUTHOR:					Jan Richter-Brockmann
--
-- CREATE DATE:			    23/04/2020
-- LAST CHANGES:            23/04/2020
-- MODULE NAME:			    BIKE_GENERIC_BRAM_SHARED_SAMP
--
-- REVISION:				1.00 - File created.
--
-- LICENCE: 				Please look at licence.txt
-- USAGE INFORMATION:	    Please look at readme.txt. If licence.txt or readme.txt
--							are missing or	if you have questions regarding the code
--							please contact Tim G�neysu (tim.gueneysu@rub.de) and
--                          Jan Richter-Brockmann (jan.richter-brockmann@rub.de)
--
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
-- KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
-- PARTICULAR PURPOSE.
----------------------------------------------------------------------------------



-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.NUMERIC_STD.ALL;

LIBRARY UNISIM;
    USE UNISIM.vcomponents.ALL;
LIBRARY UNIMACRO;
    USE unimacro.Vcomponents.ALL;

LIBRARY work;
    USE work.BIKE_SETTINGS.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY BIKE_GENERIC_BRAM_SHARED_SAMP IS
	PORT ( 
	   -- CONTROL PORTS ----------------
        CLK             : IN  STD_LOGIC; 	
        RESET           : IN  STD_LOGIC;
        -- SAMPLING --------------------
        REN0_SAMP       : IN  STD_LOGIC;
        REN1_SAMP       : IN  STD_LOGIC;
        WEN0_SAMP       : IN  STD_LOGIC;
        WEN1_SAMP       : IN  STD_LOGIC;
        ADDR0_SAMP      : IN  STD_LOGIC_VECTOR(LOG2(R_BLOCKS)-1 DOWNTO 0);
        ADDR1_SAMP      : IN  STD_LOGIC_VECTOR(LOG2(R_BLOCKS)-1 DOWNTO 0);
        DOUT0_SAMP      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DOUT1_SAMP      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DIN0_SAMP       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        DIN1_SAMP       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END BIKE_GENERIC_BRAM_SHARED_SAMP;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF BIKE_GENERIC_BRAM_SHARED_SAMP IS



-- CONSTANTS
----------------------------------------------------------------------------------
CONSTANT NUM_OF_BRAM : NATURAL := CEIL(R_BITS, BRAM_CAP);



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL REN_BRAM0, REN_BRAM1 : STD_LOGIC;
SIGNAL WREN_A, WREN_B       : STD_LOGIC;
SIGNAL ADDR_A, ADDR_B       : STD_LOGIC_VECTOR( 9 DOWNTO 0);
SIGNAL DIN_A, DIN_B         : STD_LOGIC_VECTOR(31 DOWNTO 0);  
SIGNAL DOUT_A, DOUT_B       : STD_LOGIC_VECTOR(31 DOWNTO 0); 



-- BEHAVIORAL
----------------------------------------------------------------------------------
BEGIN

    -- SIGNAL ASSIGNMENT ---------------------------------------------------------   
    -- reading
    --RDEN_SAMP   <= REN0_SAMP OR REN1_SAMP;
    REN_BRAM0   <= REN0_SAMP;
    REN_BRAM1   <= REN1_SAMP;
     
    -- writing
    WREN_A <= WEN0_SAMP;
    WREN_B <= WEN1_SAMP;
    
    -- addresses
    I0 : IF LOG2(R_BLOCKS) >= 9 GENERATE
        ADDR_A <= '0' & ADDR0_SAMP;
        ADDR_B <= '1' & ADDR1_SAMP;
    END GENERATE;
    
    I1 : IF LOG2(R_BLOCKS) <= 8 GENERATE
        ADDR_A <= '0' & (8 DOWNTO LOG2(R_BLOCKS) => '0') & ADDR0_SAMP;
        ADDR_B <= '1' & (8 DOWNTO LOG2(R_BLOCKS) => '0') & ADDR1_SAMP;  
    END GENERATE;
     
    -- inputs
    DIN_A <= DIN0_SAMP;
    DIN_B <= DIN1_SAMP;
    
    -- outputs
    DOUT0_SAMP <= DOUT_A;
    DOUT1_SAMP <= DOUT_B;
    ------------------------------------------------------------------------------
    
    -- BRAM INSTANTIATION --------------------------------------------------------
    BRAM : ENTITY work.BIKE_BRAM_DUAL_PORT
    PORT MAP(
        -- CONTROL PORTS -----------
        CLK             => CLK,     
        RESET           => RESET,
        WEN_A           => WREN_A,
        WEN_B           => WREN_B,
        REN_A           => REN_BRAM0,
        REN_B           => REN_BRAM1,
        -- I/O ---------------------
        ADDR_A          => ADDR_A,
        ADDR_B          => ADDR_B,
        DOUT_A          => DOUT_A,
        DOUT_B          => DOUT_B,
        DIN_A           => DIN_A,
        DIN_B           => DIN_B
    );
    ------------------------------------------------------------------------------  

END Behavioral;