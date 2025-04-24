/*
* DPA_1bit_mul_v.sv
* Created on: 10.2.2024
*
* MUL gate based on TI and DOM for DPA resistance.
* Variable number of shares version.
* Done in one (1) clock cycle.
*
* Parameters:
*       NUMBER_OF_SHARES - number of shares.
*
* Inputs:
*       x -     Array of the shares of the variable x.
*               The register is one (1) bit long.
*                   Each share is one (1) bit long.
*                   The number of shares is NUMBER_OF_SHARES.
*       y -     Array of the shares of the variable y.
*               The register is one (1) bit long.
*                   Each share is one (1) bit long.
*                   The number of shares is NUMBER_OF_SHARES.
*       r -     Array of fresh random shares.
*               The register is one (1) bit long.
*                   Each share is one (1) bit long.
*                   The number of shares is (((NUMBER_OF_SHARES - 1)*NUMBER_OF_SHARES)/2).
*       clock - Clock bit.
*               Low to high sensitive.
*
* Output:
*       q -     Array of the shares of the multiplication result.
*               The register is one (1) bit long.
*                   Each share is one (1) bit long.
*                   The number of shares is NUMBER_OF_SHARES.
*/
module DPA_1bit_mul_v #(parameter NUMBER_OF_SHARES = 3) (
    input logic [NUMBER_OF_SHARES - 1 : 0] x,
    input logic [NUMBER_OF_SHARES - 1 : 0] y,
    input logic [(((NUMBER_OF_SHARES - 1)*NUMBER_OF_SHARES)/2) - 1 : 0] r,

    input logic clock,

    output logic [NUMBER_OF_SHARES - 1 : 0] q
);

logic [NUMBER_OF_SHARES - 1 : 0] resharing_xor[NUMBER_OF_SHARES - 1 : 0];
logic [NUMBER_OF_SHARES - 1 : 0] ff_for_resharing[NUMBER_OF_SHARES - 1 : 0];

always_comb begin : resharing_block
    int r_index;
    int low_index;
    int high_index;
    for (int x_share_number = 0; x_share_number < NUMBER_OF_SHARES; x_share_number++) begin: resharing_mat_block
        for (int y_share_number = 0; y_share_number < NUMBER_OF_SHARES; y_share_number++) begin
            if(x_share_number == y_share_number) begin
                resharing_xor[x_share_number][y_share_number] = x[x_share_number] & y[y_share_number];
            end
            else begin
                low_index = x_share_number < y_share_number ? x_share_number : y_share_number;
                high_index = x_share_number < y_share_number ? y_share_number : x_share_number;
                r_index = ((low_index * NUMBER_OF_SHARES) - ((low_index * (low_index + 1)) / 2)) + (high_index - (low_index + 1));
                resharing_xor[x_share_number][y_share_number] = r[r_index] ^ (x[x_share_number] & y[y_share_number]);
            end
        end
    end
end

always_ff @( posedge clock ) begin : resharing_bottom_block
    ff_for_resharing <= resharing_xor;
end

// integration
always_comb begin : integration_block
    for (int q_share_index = 0; q_share_index < NUMBER_OF_SHARES; q_share_index++) begin
        q[q_share_index] = ^ff_for_resharing[q_share_index];
    end
end

endmodule