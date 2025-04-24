/*
* DPA_or_v.sv
* Created on: 10.2.2024
*
* OR gate based on TI and DOM for DPA resistance.
* Variable size and number of shares version.
* Done in one (1) clock cycle.
* 
* Parameters:
*     REGISTER_WIDTH - width of the input and output registers.
*     NUMBER_OF_SHARES - number of shares.
*
* Input:
*       x -     Array of the shares per bit of the variable x.
*               Little endian.
*               The register is REGISTER_WIDTH bits long.
*                   Each share is one (1) bit long.
*                   The number of shares is NUMBER_OF_SHARES.
*       y -     Array of the shares per bit of the variable x.
*               Little endian.
*               The register is REGISTER_WIDTH bits long.
*                   Each share is one (1) bit long.
*                   The number of shares is NUMBER_OF_SHARES.
*       r -     Array of fresh random shares.
*               The register is REGISTER_WIDTH bits long.
*                   Each share is one (1) bit long.
*                   The number of shares per bit is (((NUMBER_OF_SHARES - 1)*NUMBER_OF_SHARES)/2).
*       clock - Clock bit.
*               Low to high sensitive.
*
* Output:
*       s -     Array of the shares of the OR result.
*               The register is one REGISTER_WIDTH bits long.
*               Little endian.
*                   Each share is one (1) bit long.
*                   The number of shares is NUMBER_OF_SHARES.
*/
module DPA_or_v #(parameter REGISTER_WIDTH = 32, NUMBER_OF_SHARES = 3) (
    input logic [NUMBER_OF_SHARES - 1 : 0] x [REGISTER_WIDTH - 1 : 0],
    input logic [NUMBER_OF_SHARES - 1 : 0] y [REGISTER_WIDTH - 1 : 0],
    input logic [((NUMBER_OF_SHARES - 1)*NUMBER_OF_SHARES/2) - 1 : 0] r [REGISTER_WIDTH],

    input logic clock,

    output logic [NUMBER_OF_SHARES - 1 : 0] s [REGISTER_WIDTH - 1 : 0]
);

logic [NUMBER_OF_SHARES - 1 : 0] x_inv [REGISTER_WIDTH - 1 : 0];
logic [NUMBER_OF_SHARES - 1 : 0] y_inv [REGISTER_WIDTH - 1 : 0];
logic [NUMBER_OF_SHARES - 1 : 0] res [REGISTER_WIDTH - 1 : 0];

generate
    for (genvar bit_index =0; bit_index < REGISTER_WIDTH; bit_index++) begin: bitwise_mul_block
        DPA_1bit_mul_v #(NUMBER_OF_SHARES) or_mul (
            .x(x_inv[bit_index]),
            .y(y_inv[bit_index]),
            .r(r[bit_index]),
            .clock(clock),
            .q(res[bit_index]));
    end
endgenerate

always_comb begin
    for (int bit_index =0; bit_index < REGISTER_WIDTH; bit_index++) begin: bitwise_inv_block
        for (int share_index =0; share_index < NUMBER_OF_SHARES; share_index++) begin
            if (share_index == 0) begin
                x_inv[bit_index][0] <= ~x[bit_index][0];
                y_inv[bit_index][0] <= ~y[bit_index][0];
                s[bit_index][0] <= ~res[bit_index][0];
            end
            else begin
                x_inv[bit_index][share_index] <= x[bit_index][share_index];
                y_inv[bit_index][share_index] <= y[bit_index][share_index];
                s[bit_index][share_index] <= res[bit_index][share_index];
            end
        end
    end
end

endmodule