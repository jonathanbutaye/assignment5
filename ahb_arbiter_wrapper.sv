`timescale 1ns/1ns 

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
    no_multiple_grants: assert property ( @(posedge HCLK) (HGRANTx |-> ((HGRANTx & (HGRANTx - 1)) == 0) ));
    
    // ASSERTION 2
    /* grant is always given */
    grant_always_given: assert property ( @(posedge HCLK) (HBUSREQx |-> ##[0:$] HGRANTx) );

    // ASSERTION 3
    /* grant goes LOW after a ready */
    grant_LOW_after_ready: assert property ( @(posedge HCLK) (HREADY |=> HGRANTx == 0));

endmodule : ahb_arbiter_wrapper
