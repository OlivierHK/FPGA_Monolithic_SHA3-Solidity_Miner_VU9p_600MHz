--------------------------------------------------------------------------------
-- PROJECT: ALTO FPGA Miner. SHA3-Solidity Flavor on Virtex ULTRAScale XCVU9P
--------------------------------------------------------------------------------
-- AUTHORS: Olivier FAURIE <olivier.faurie.hk@gmail.com>
-- LICENSE: 
-- WEBSITE: https://github.com/olivierHK
---------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     IEEE.MATH_REAL.ALL;

library work;
use     work.MyPackage.all;

-------------------------------------------------------------------------------------------------------
------------------------------------------TOP ENTITY---------------------------------------------------
-------------------------------------------------------------------------------------------------------
entity PIPELINE_TOP_MODULE is
    Port (
        -- Hashing Clock.
        i_CLK                     : in    std_logic; 

        -- header/enable forward Pipeline
        i_HASH_en                 : in   std_logic;
        o_HASH_en_delay           : out  bit_bus_type ;

        i_header_chunck           : in   std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
        o_header_chunck_delay     : out  header64_bus_type;

        -- valid/Gticket backward Pipeline
        i_valid_out               : in   bit_bus_type;
        o_valid_out_delay         : out  std_logic;

        i_GoldenTicket_core       : in   bit_bus_type;
        o_GoldenTicket_core_delay : out  bit_bus_type;

        i_GoldenNonce_core        : in    header64_bus_type;
        o_GoldenNonce_core_delay  : out   header64_bus_type

    );
    
end entity;
-------------------------------------------------------------------------------------------------------



architecture ARCH of PIPELINE_TOP_MODULE is



    -------------------------------------------------------------------------------------------------------
    -------------------------------------PIPELINE FORWARD--------------------------------------------------
    -------------------------------------------------------------------------------------------------------
    component PIPELINE_FORWARD_MODULE
        Port (
            -- Hashing Clock.
            i_CLK                     : in    std_logic; 

            -- header/enable forward Pipeline
            i_HASH_en                 : in   std_logic;
            o_HASH_en_delay           : out  bit_bus_type ;

            i_header_chunck           : in   std_logic_vector ( (BLOCK_HEADER_CHUNK_WIDTH-1) downto 0);
            o_header_chunck_delay     : out  header64_bus_type
        );
    end component PIPELINE_FORWARD_MODULE;
    
    -----------------------------------------------//---------------------------------------------------------



    -------------------------------------------------------------------------------------------------------
    -------------------------------------PIPELINE BACKWARD-------------------------------------------------
    -------------------------------------------------------------------------------------------------------
    component PIPELINE_BACKWARD_MODULE
        Port (
            -- Hashing Clock.
            i_CLK                     : in    std_logic; 

            -- valid/Gticket backward Pipeline
            i_valid_out               : in   bit_bus_type;
            o_valid_out_delay         : out  std_logic;

            i_GoldenTicket_core       : in   bit_bus_type;
            o_GoldenTicket_core_delay : out  bit_bus_type;

            i_GoldenNonce_core        : in    header64_bus_type;
            o_GoldenNonce_core_delay   : out   header64_bus_type
        );
    end component PIPELINE_BACKWARD_MODULE;
    
    -----------------------------------------------//---------------------------------------------------------



    signal r_HASH_en_delay            : bit_bus_type ;
    signal r_header_chunck_delay      : header64_bus_type;

    signal  r_valid_out_delay         : std_logic;      
    signal  r_GoldenTicket_core_delay : bit_bus_type;

    signal r_GoldenNonce_core_delay    :header64_bus_type;
   

    begin
        ---------------------------------------------------------
        -----------PIPELINE FORWARD Module-----------------------
        ---------------------------------------------------------
        u_PIPELINE_FORWARD_MODULE: PIPELINE_FORWARD_MODULE

        port map (
            -- Hashing Clock.
            i_CLK                  => i_CLK,

            -- header/enable forward Pipeline
            i_HASH_en              => i_HASH_en,
            o_HASH_en_delay        => r_HASH_en_delay,

            i_header_chunck        => i_header_chunck,
            o_header_chunck_delay  => r_header_chunck_delay
        );
        ----------
        o_HASH_en_delay       <= r_HASH_en_delay;      
        o_header_chunck_delay <= r_header_chunck_delay;




        ---------------------------------------------------------
        -----------PIPELINE BACKWARD Module----------------------
        ---------------------------------------------------------
        u_PIPELINE_BACKWARD_MODULE: PIPELINE_BACKWARD_MODULE

        port map (
            -- Hashing Clock.
            i_CLK                     => i_CLK,

            -- valid/Gticket backward Pipeline
            i_valid_out               => i_valid_out,
            o_valid_out_delay         => r_valid_out_delay,

            i_GoldenTicket_core       => i_GoldenTicket_core,
            o_GoldenTicket_core_delay => r_GoldenTicket_core_delay,

            i_GoldenNonce_core        => i_GoldenNonce_core,
            o_GoldenNonce_core_delay   => r_GoldenNonce_core_delay
        );
        ----------
        o_valid_out_delay         <= r_valid_out_delay;      
        o_GoldenTicket_core_delay <= r_GoldenTicket_core_delay;
        o_GoldenNonce_core_delay  <= r_GoldenNonce_core_delay;


end architecture;