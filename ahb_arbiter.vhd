--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     xoodoo_chi - Behavioural
-- Project Name:    LWC Xoodyak
-- Description:     Round function chi
--
-- Revision     Date       Author     Comments
-- v1.0         20200701   VlJo       Initial version
--
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.ALL;
    -- use IEEE.numeric_std.ALL;
    use ieee.std_logic_misc.or_reduce;

entity ahb_arbiter is
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
end ahb_arbiter;

architecture Behavioural of ahb_arbiter is

    constant C_FORCE_MULTIPLE_GRANT : STD_LOGIC := '0';
    constant C_DENY_GRANT_MA02 : STD_LOGIC := '1';

    signal HCLK_i : STD_LOGIC;
    signal HRESETn_i : STD_LOGIC;
    signal HBUSREQx_i : STD_LOGIC_VECTOR(15 downto 0);
    signal HLOCKx_i : STD_LOGIC_VECTOR(15 downto 0);
    signal HGRANTx_i : STD_LOGIC_VECTOR(15 downto 0);
    signal HSPLIT_i : STD_LOGIC_VECTOR(15 downto 0);
    signal HREADY_i : STD_LOGIC;
    signal HMASTER_i : STD_LOGIC_VECTOR(3 downto 0);
    signal HMASTLOCK_i : STD_LOGIC;

    signal pointer, locked : STD_LOGIC_VECTOR(15 downto 0);
    signal req : STD_LOGIC;

    type Tstates is (sIdle, sRequested, sGranted);
    signal curState, nxtState : Tstates;

    signal fsm_o_rot_pointer, fsm_o_ld_lock : STD_LOGIC;

begin
  
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    HCLK_i <= HCLK;
    HRESETn_i <= HRESETn;
    HBUSREQx_i <= HBUSREQx;
    HLOCKx_i <= HLOCKx;
    HSPLIT_i <= HSPLIT;
    HREADY_i <= HREADY;
    HMASTER <= HMASTER_i;
    HMASTLOCK <= HMASTLOCK_i;



    HGRANTx(1 downto 0) <= HGRANTx_i(1 downto 0);
    HGRANTx(14 downto 3) <= HGRANTx_i(14 downto 3);

    DENY_GRANT_MA02: if C_DENY_GRANT_MA02='1' generate
        HGRANTx(2) <= '0';
    end generate DENY_GRANT_MA02;
    DENY_GRANT_MA02_n: if C_DENY_GRANT_MA02='0' generate
        HGRANTx(2) <= HGRANTx_i(2);
    end generate DENY_GRANT_MA02_n;

    FORCE_MULTIPLE_GRANT: if C_FORCE_MULTIPLE_GRANT='1' generate
        HGRANTx(15) <= HGRANTx_i(1);
    end generate FORCE_MULTIPLE_GRANT;
    FORCE_MULTIPLE_GRANT_n: if C_FORCE_MULTIPLE_GRANT='0' generate
        HGRANTx(15) <= HGRANTx_i(15);
    end generate FORCE_MULTIPLE_GRANT_n;

    

    -------------------------------------------------------------------------------
    -- REGISTER
    -------------------------------------------------------------------------------
    PREG: process(HRESETn_i, HCLK_i)
    begin
        if HRESETn_i = '0' then 
            pointer <= (0 => '1', others => '0');
            locked <= (others => '0');
        elsif rising_edge(HCLK_i) then
            if fsm_o_rot_pointer = '1' then 
                pointer <= pointer(14 downto 0) & pointer(15);
            end if;
            if fsm_o_ld_lock = '1' then 
                locked <= HLOCKx_i and pointer;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    req <= or_reduce(pointer and HBUSREQx_i);

    HGRANTx_i <= pointer and HBUSREQx_i when curState /= sIdle else (others => '0');
    HMASTLOCK_i <= or_reduce(locked);

    PMUX_HMASTER: process(pointer)
    begin
        case pointer is
            when x"0002" => HMASTER_i <= x"1";
            when x"0004" => HMASTER_i <= x"2";
            when x"0008" => HMASTER_i <= x"3";
            when x"0010" => HMASTER_i <= x"4";
            when x"0020" => HMASTER_i <= x"5";
            when x"0040" => HMASTER_i <= x"6";
            when x"0080" => HMASTER_i <= x"7";
            when x"0100" => HMASTER_i <= x"8";
            when x"0200" => HMASTER_i <= x"9";
            when x"0400" => HMASTER_i <= x"A";
            when x"0800" => HMASTER_i <= x"B";
            when x"1000" => HMASTER_i <= x"C";
            when x"2000" => HMASTER_i <= x"D";
            when x"4000" => HMASTER_i <= x"E";
            when x"8000" => HMASTER_i <= x"F";
            when others => HMASTER_i <= x"0";
        end case;
    end process;

    -------------------------------------------------------------------------------
    -- FSM
    -------------------------------------------------------------------------------
    -- FSM NEXT STATE FUNCTION
    P_FSM_NSF: process(curState, req, HREADY_i)
    begin
        nxtState <= curState;

        case curState is
            when sIdle =>
                if req = '1' then
                    nxtState <= sRequested;
                end if;

            when sRequested =>
                nxtState <= sGranted;

            when sGranted =>
                if HREADY_i = '1' then 
                    nxtState <= sIdle;
                end if;

            when others =>
                nxtState <= sIdle;
        end case;
    end process;

    -- FSM STATE REGISTER
    P_FSM_STATEREG: process(HRESETn_i, HCLK_i)
    begin
        if HRESETn_i = '0' then 
            curState <= sIdle;
        elsif rising_edge(HCLK_i) then 
            curState <= nxtState;
        end if;
    end process;


    fsm_o_rot_pointer <= '1' when curState = sIdle and nxtState = sIdle else '0';
    fsm_o_ld_lock <= not(fsm_o_rot_pointer);


end Behavioural;
