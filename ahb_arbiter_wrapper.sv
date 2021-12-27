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
    initial begin
        no_multiple_grants: assert ($onehot0(HGRANTx)) else $error("More than one grant given to masters");
    end
    // Bad way that also works
    /* simple trick to check wether a number has more than one bit set: n & (n - 1) != 0 */
    //no_multiple_grants: assert property ( @(posedge HCLK) (HGRANTx |-> ((HGRANTx & (HGRANTx - 1)) == 0) ));
    
    // ASSERTION 2
    /* grant is always given */
    sequence grant_always_seq;
        @(posedge HCLK) HBUSREQx ##[0:$] HGRANTx;
    endsequence
    property grant_always_prop;
        grant_always_seq;
    endproperty
    grant_always_given: assert property(grant_always_prop);
    //grant_always_given: assert property ( @(posedge HCLK) (HBUSREQx |-> ##[0:$] HGRANTx) );

    // ASSERTION 3
    /* grant goes LOW after a ready */
    grant_LOW_after_ready: assert property ( @(posedge HCLK) (HREADY |=> HGRANTx == 0));

    // ASSERTION 4
    /* I assume that grant will be given within 16 clockcycles when there is only one master a high request signal */
    /* It is enough to check if one grant is given instead of first checking wich master is requesting because only one master is requesting */
    /* I used the same trick as in assertion 1 to check if only one bit is set */
    
    grant_within_16_clkcycles: assert property ( @(posedge HCLK) ($onehot(HBUSREQx) |-> ##[0:16] $onehot(HGRANTx)));

    // ASSERTION 5
    /* I assume that grant is given or will be within 16 clockcycles when there is at least one request */
    // Very similar to assertion 4
    grant_given: assert property ( @(posedge HCLK) ($countones(HBUSREQx) >= 1 |-> ##[0:16] $onehot(HGRANTx)));

    // ASSERTION 6
    /* I assume that there must be at least one request and the grant signal must be high when the ready signal rises */
    request_when_ready: assert property ( @(posedge HCLK) (HREADY |-> $countones(HBUSREQx)>=1 && $onehot(HGRANTx)));

endmodule : ahb_arbiter_wrapper
