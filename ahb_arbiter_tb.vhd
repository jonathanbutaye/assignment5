--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     ahb_master_tb - Behavioural
-- Project Name:    cdandverif
-- Description:     Round-robin AHB arbiter
--
-- Revision     Date       Author     Comments
-- v1.0         20211129   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.ALL;
    use ieee.std_logic_misc.or_reduce;


entity ahb_arbiter_tb is
end ahb_arbiter_tb;

architecture Behavioural of ahb_arbiter_tb is

    component ahb_arbiter_wrapper is
        port(
            HCLK : in STD_LOGIC;
            HRESETn : in STD_LOGIC;

            HBUSREQx : in STD_LOGIC_VECTOR(15 downto 0);
            HLOCKx : in STD_LOGIC_VECTOR(15 downto 0);
            HGRANTx : out STD_LOGIC_VECTOR(15 downto 0);
            
            HSPLIT : in STD_LOGIC_VECTOR(15 downto 0);
            HREADY : in STD_LOGIC;
            
            HMASTER : out STD_LOGIC_VECTOR(3 downto 0);
            HMASTLOCK : out STD_LOGIC
        );
    end component;

    constant clock_period: time := 10 ns;

    signal HCLK : STD_LOGIC;
    signal HRESETn : STD_LOGIC;
    signal HBUSREQx : STD_LOGIC_VECTOR(15 downto 0);
    signal HLOCKx : STD_LOGIC_VECTOR(15 downto 0);
    signal HGRANTx : STD_LOGIC_VECTOR(15 downto 0);
    signal HSPLIT : STD_LOGIC_VECTOR(15 downto 0);
    signal HREADY : STD_LOGIC;
    signal HMASTER : STD_LOGIC_VECTOR(3 downto 0);
    signal HMASTLOCK : STD_LOGIC;

    signal pointer : integer;
    signal ready_indiv : STD_LOGIC_VECTOR(15 downto 0);

begin

    -------------------------------------------------------------------------------
    -- STIMULI
    -------------------------------------------------------------------------------
    HREADY <= or_reduce(ready_indiv);
    process
    begin
        HGRANTx <= '0';
        HRESETn <= '0';
        HBUSREQx <= (others => '0');
        HLOCKx <= (others => '0');
        HSPLIT <= (others => '0');
        ready_indiv <= (others => '0');
        pointer <= 0;
        wait for clock_period*10;

        HRESETn <= '1';
        wait for clock_period*10;

        -- REQUEST M0
        pointer <= 0; wait for clock_period;
        HBUSREQx <= (pointer => '1', others => '0');
        wait until HGRANTx(pointer) = '1';
        wait for clock_period*10;
        ready_indiv <= (pointer => '1', others => '0');
        wait for clock_period;
        HBUSREQx <= (others => '0');
        ready_indiv <= (others => '0');
        wait for clock_period*10;

        -- REQUEST M1
        pointer <= 1; wait for clock_period;
        HBUSREQx <= (pointer => '1', others => '0');
        wait until HGRANTx(pointer) = '1';
        wait for clock_period*10;
        ready_indiv <= (pointer => '1', others => '0');
        wait for clock_period;
        HBUSREQx <= (others => '0');
        ready_indiv <= (others => '0');
        wait for clock_period*10;

        -- REQUEST M2
        pointer <= 2; wait for clock_period;
        HBUSREQx <= (pointer => '1', others => '0');
        HLOCKx <= (pointer => '1', others => '0');
        wait until HGRANTx(pointer) = '1';
        wait for clock_period*10;
        ready_indiv <= (pointer => '1', others => '0');
        wait for clock_period;
        HBUSREQx <= (others => '0');
        HLOCKx <= (others => '0');
        ready_indiv <= (others => '0');
        wait for clock_period*10;

        -- REQUEST M0 & M1
        wait for clock_period*5;
        HBUSREQx <= (0 => '1', 1 => '1', others => '0');
        wait until HGRANTx(0) = '1' or HGRANTx(1) = '1';
        wait for clock_period*10;
        ready_indiv <= (1 => '1', others => '0');
        wait for clock_period;
        HBUSREQx <= (0 => '1', others => '0');
        ready_indiv <= (others => '0');
        
        wait for clock_period;
        pointer <= 0;
        wait until HGRANTx(pointer) = '1';
        wait for clock_period*10;
        ready_indiv <= (pointer => '1', others => '0');
        wait for clock_period;
        HBUSREQx <= (others => '0');
        ready_indiv <= (others => '0');
        wait for clock_period*10;
        wait for clock_period*10;

        wait for clock_period*100;
        wait;
    end process;

    -------------------------------------------------------------------------------
    -- DUT
    -------------------------------------------------------------------------------
    DUT: component ahb_arbiter_wrapper port map(
        HCLK => HCLK,
        HRESETn => HRESETn,
        HBUSREQx => HBUSREQx,
        HLOCKx => HLOCKx,
        HGRANTx => HGRANTx,
        HSPLIT => HSPLIT,
        HREADY => HREADY,
        HMASTER => HMASTER,
        HMASTLOCK => HMASTLOCK
    );

    -------------------------------------------------------------------------------
    -- CLOCK
    -------------------------------------------------------------------------------
    process
    begin
        HCLK <= '1';
        wait for clock_period/2;
        HCLK <= '0';
        wait for clock_period/2;
    end process;

end Behavioural;
