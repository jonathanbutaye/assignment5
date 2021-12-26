`timescale 10ns/1ns 

module ahb_arbiter_wrapper (
    input logic HCLK,
    input logic HRESETn,
    input logic [15:0] HBUSREQx,
    input logic [15:0] HLOCKx,
    output logic [15:0] HGRANTx,
    input logic [15:0] HSPLIT,
    input logic HREADY,
    output [3:0] HMASTER,
    output HMASTLOCK
);

    ahb_arbiter ahb_arbiter_inst00 (
        HCLK, HRESETn, 
        HBUSREQx, HLOCKx, HGRANTx, HSPLIT,
        HREADY, HMASTER, HMASTLOCK
    );

    /* hic sunt dracones */
    // ASSERTION 1
    /* grant can never been given to more than one master */
    /* simple trick to check wether a number has more than one bit set: n & (n - 1) != 0 */
    no_multiple_grants: assert (HGRANTx |-> ((HGRANTx & (HGRANTx - 1)) == 0) ) $display("%m pass"); else $info("%m fail");
    
    // ASSERTION 2
    /* grant is always given */
    grant_always_given: assert property ( @(posedge HCLK) (HBUSREQx |-> ##[0:$] HGRANTx) );

    // ASSERTION 3
    /* grant goes LOW after a ready */
    grant_LOW_after_ready: assert property ( @(posedge HCLK) (HREADY |=> HGRANTx == 0));

    // ASSERTION 4
    /* I assume that grant will be given within 16 clockcycles when there is only one master a high request signal */
    /* It is enough to check if one grant is given instead of first checking wich master is requesting because only one master is requesting */
    /* I used the same trick as in assertion 1 to check if only one bit is set */
    
    //grant_within_16_clkcycles: assert property ( @(posedge HCLK) (((HBUSREQx & (HBUSREQx - 1)) == 0) |-> ##[1:16] HGRANTx));

    // ASSERTION 5
    /* I assume */


endmodule : ahb_arbiter_wrapper
