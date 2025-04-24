module DPA_alu_tb;

`include "../lib/types.sv"
`include "../lib/register_gens.sv"
`include "../lib/uut_modules_types.sv"
`include "../lib/uut_modules_methods.sv"

DPA_alu_tb_t test_struct;

// units
logic clk;
DPA_clock #(5) clk_gen (
    .clk(clk)
);

DPA_alu #(32, 3) uut (
    .reg_1(test_struct.uut_struct.uut_reg_1),
    .const_w(test_struct.uut_struct.uut_const_w),
    .const_0(test_struct.uut_struct.uut_const_0),
    .carry_in(test_struct.uut_struct.uut_carry_in),
    .reg_2(test_struct.uut_struct.uut_reg_2),
    .r_1(test_struct.uut_struct.uut_fresh_shares_1),
    .r_2(test_struct.uut_struct.uut_fresh_shares_2),
    .r_3(test_struct.uut_struct.uut_fresh_shares_3),
    .reg_1_sel(test_struct.uut_struct.uut_reg_1_sel),
    .invert_sel(test_struct.uut_struct.uut_invert_sel),
    .function_array_sel(test_struct.uut_struct.uut_function_array_sel),
    .shift_sel(test_struct.uut_struct.uut_shift_sel),
    .clock(clk),
    .enable(test_struct.uut_struct.uut_enable),
    .carry_out(test_struct.uut_struct.uut_carry_out),
    .alu_out(test_struct.uut_struct.uut_alu_out),
    .ready(test_struct.uut_struct.uut_ready)
);

task test_reg1_reg2_add;
    // reg_1_sel, invert_sel, function_array_sel, shift_sel
    // reg1, no invert, add, no shift

    printTestName("Testing reg1 + reg2");
    test_struct = initAluTest(2'b00, 0, 2'b00, 3'b000);
    test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
    for(int i = 0; i < 1; i++) begin
        @(posedge clk);
    end
    test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);
    wait(test_struct.uut_struct.uut_ready == 1);

    test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
    checkAluUutOutput(test_struct);
endtask

task test_reg1_shift_right_arithmetic_reg2_add;
    // reg1, no invert, add, shift right arithmetic

    printTestName("Testing reg1 + (reg2 >>> 1)");
    test_struct = initAluTest(2'b00, 0, 2'b00, 3'b001);
    test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
    for(int i = 0; i < 1; i++) begin
        @(posedge clk);
    end
    test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);

    wait(test_struct.uut_struct.uut_ready == 1);

    test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
    checkAluUutOutput(test_struct);
endtask

task test_reg1_shift_left_logical_reg2_add;
    // reg1, no invert, add, shift left logical
    test_struct = initAluTest(2'b00, 0, 2'b00, 3'b010);
    test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
    @(posedge clk);
    test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);

    wait(test_struct.uut_struct.uut_ready == 1);

    test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
    checkAluUutOutput(test_struct);
endtask

task test_reg1_shift_right_logical_reg2_add;
    // reg1, no invert, add, shift right logical

    printTestName("Testing reg1 + (reg2 << 1)");
    test_struct = initAluTest(2'b00, 0, 2'b00, 3'b011);
    test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
    @(posedge clk);
    test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);

    wait(test_struct.uut_struct.uut_ready == 1);

    test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
    checkAluUutOutput(test_struct);
endtask

task test_reg1_add_reg2_negative;
    printTestName("Testing 5 + (-3)");
    // reg1, no invert, add, no shift
    test_struct = initAluTestConstRegs(5, -3, 55, 0, 2'b00, 0, 2'b00, 3'b000);
    test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
    for(int i = 0; i < 1; i++) begin
        @(posedge clk);
    end
    test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);
    wait(test_struct.uut_struct.uut_ready == 1);

    test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
    checkAluUutOutput(test_struct);

    printTestName("Testing (-1) + (2)");
    // reg1, no invert, add, no shift
    test_struct = initAluTestConstRegs(-1, 2, 55, 0, 2'b00, 0, 2'b00, 3'b000);
    test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
    for(int i = 0; i < 1; i++) begin
        @(posedge clk);
    end
    test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);
    wait(test_struct.uut_struct.uut_ready == 1);

    test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
    checkAluUutOutput(test_struct);
endtask

task test_const0_add_reg2_zero;
    printTestName("Testing 0 + (0)");
    // const0, no invert, add, no shift
    test_struct = initAluTestConstRegs(15, 0, 55, 0, 2'b10, 0, 2'b00, 3'b000);
    test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
    for(int i = 0; i < 1; i++) begin
        @(posedge clk);
    end
    test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);
    wait(test_struct.uut_struct.uut_ready == 1);

    test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
    checkAluUutOutput(test_struct);
endtask

task test_random;
    for (int run_index = 0; run_index < 100; run_index++) begin
        $display("========= Random test run %d =========", run_index);
        @(posedge clk);
        test_struct = initAluTest($urandom, $urandom, $urandom, $urandom);
        test_struct.uut_struct = turnAluUutOff(test_struct.uut_struct);
        @(posedge clk);
        test_struct.uut_struct = turnAluUutOn(test_struct.uut_struct);
        wait(test_struct.uut_struct.uut_ready == 1);
        @(posedge clk);
        test_struct.uut_struct = readAndPrintAluUutOutput(test_struct.uut_struct);
        checkAluUutOutput(test_struct);
    end
endtask

initial begin
    $display("Starting test");
    #5;

    // Direct tests
    test_reg1_reg2_add();
    test_reg1_shift_right_arithmetic_reg2_add();
    test_reg1_shift_left_logical_reg2_add();
    test_reg1_shift_right_logical_reg2_add();

    test_reg1_add_reg2_negative();
    test_const0_add_reg2_zero();

    // Random test
    test_random();
    $display("Finished test");
end

endmodule