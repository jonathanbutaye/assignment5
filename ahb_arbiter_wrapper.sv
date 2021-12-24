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
    /* grant can never been given to more than one master */
    /* simple trick to check wether a number has more than one bit set: n & (n - 1) != 0 */
    initial 
    begin
        no_multiple_grants: assert ((HGRANTx && (HGRANTx - 1)) == 0) $display("%m pass"); else $info("%m fail");
    end
    

endmodule : ahb_arbiter_wrapper
