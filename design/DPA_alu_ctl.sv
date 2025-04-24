/*
* DPA_alu_ctl.sv
* Created on: 16.3.2024
*
* ALU control logic.
*
* Input:
*      function_array_sel - Select signal for the function array.
*                           The signal is 2 bits long.
*                               00 - ADD
*                               01 - OR
*                               10 - XOR
*                               11 - AND
*       clock -             Clock bit.
*                           Low to high sensitive.
*       enable -            Enable bit.
*                           Low to high sensitive.
*
* Output:
*       ready -             Ready bit.
*/
module DPA_alu_ctl (
    // Control signals
    input logic[1:0] function_array_sel,
    input logic clock,
    input logic enable,

    // Outputs
    output logic ready
);

`include "defs.sv"

// Clock counter for the ready signal
logic [`NUMBER_OF_BITS_TO_COUNT_ALU_READY - 1 : 0] clock_counter;

always_ff @(posedge clock) begin
    if(enable) begin
        case(function_array_sel)
            `FUNC_ARR_SEL_ADD: begin
                if(clock_counter < `LONG_FULL_ADD_GATE_TIME_TO_READY - 1) begin
                    clock_counter <= clock_counter + 1;
                end
                else begin
                    ready <= 1;
                end
            end
            `FUNC_ARR_SEL_OR: begin
                if(clock_counter < `OR_GATE_TIME_TO_READY - 1) begin
                    clock_counter <= clock_counter + 1;
                end
                else begin
                    ready <= 1;
                end
            end
            `FUNC_ARR_SEL_XOR: begin
                ready <= 1;
            end
            `FUNC_ARR_SEL_AND: begin
                if(clock_counter < `AND_GATE_TIME_TO_READY - 1) begin
                    clock_counter <= clock_counter + 1;
                end
                else begin
                    ready <= 1;
                end
            end
        endcase
    end
    else begin
        clock_counter <= 0;
        ready <= 0;
    end
end

endmodule