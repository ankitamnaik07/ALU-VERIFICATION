module alu_tb;
  parameter N = 4;
  reg clk, rst, mode, ce, cin;
  reg [N-1:0]   opa, opb;
  reg [1:0]     inp_valid;
  reg [3:0]   cmd;

  wire [2*N-1:0] res_dut;
  wire           oflow_dut, err_dut, l_dut, e_dut, g_dut, cout_dut;

  wire [2*N-1:0] res_ref;
  wire           oflow_ref, err_ref, l_ref, e_ref, g_ref, cout_ref;

  integer pass_count, fail_count;

  ALU_rtl_design #(N) a1 (
    .CLK(clk), .RST(rst), .CE(ce), .CIN(cin), .MODE(mode),
    .OPA(opa), .OPB(opb), .CMD(cmd), .INP_VALID(inp_valid),
    .RES(res_dut), .OFLOW(oflow_dut), .ERR(err_dut),
    .L(l_dut), .E(e_dut), .G(g_dut), .COUT(cout_dut)
  );

 alu_reference_model #(N) a2 (
    .CLK(clk), .RST(rst), .CE(ce), .CIN(cin), .MODE(mode),
    .OPA(opa), .OPB(opb), .CMD(cmd), .INP_VALID(inp_valid),
    .RES(res_ref), .OFLOW(oflow_ref), .ERR(err_ref),
    .L(l_ref), .E(e_ref), .G(g_ref), .COUT(cout_ref)
  );

initial clk = 0;
always #5 clk=~clk;

 task apply;
    input [50*8:1] id;
    input          t_rst;
 input          t_mode;
    input          t_ce;
    input          t_cin;
    input [1:0]    t_inp_valid;
    input [3:0]  t_cmd;
    input [N:0]  t_opa;
    input [N:0]  t_opb;
    begin
      @(posedge clk); #1;
      rst       = t_rst;
      mode      = t_mode;
      ce        = t_ce;
      cin       = t_cin;
      inp_valid = t_inp_valid;
      cmd       = t_cmd;
      opa       = t_opa;
      opb       = t_opb;
      @(posedge clk);
      @(posedge clk);
      @(posedge clk); #1;
      if ((res_dut   == res_ref)   &&
          (err_dut   == err_ref)   &&
          (oflow_dut == oflow_ref) &&
          (g_dut     == g_ref)     &&
          (l_dut     == l_ref)     &&
          (e_dut     == e_ref)     &&
          (cout_dut  == cout_ref))
      begin
        $display("PASS [%0s] DUT: res=%b oflow=%b err=%b g=%b l=%b e=%b cout=%b",
                  id, res_dut, oflow_dut, err_dut, g_dut, l_dut, e_dut, cout_dut);
        pass_count = pass_count + 1;
      end
      else begin
        $display("FAIL [%0s]", id);
        $display("  DUT: res=%b oflow=%b err=%b g=%b l=%b e=%b cout=%b",
                  res_dut, oflow_dut, err_dut, g_dut, l_dut, e_dut, cout_dut);
        $display("  REF: res=%b oflow=%b err=%b g=%b l=%b e=%b cout=%b",                                                                            res_ref, oflow_ref, err_ref, g_ref, l_ref, e_ref, cout_ref);                                                        fail_count = fail_count + 1;
end
end
endtask
 initial begin
pass_count = 0;
fail_count = 0;
 rst       = 1;
mode      = 0;
ce        = 0;
 cin       = 0;
 inp_valid = 2'b00;
cmd       = 4'b0000;
opa       = 4'b0000;
opb       = 4'b0000;                                                            repeat (4) @(posedge clk);
rst = 0;
repeat (2) @(posedge clk);


        $display("\n---  RST mid every operation type ---");
        apply("rst_mid_logical_op",        1,0,1,0,2'b11,4'b0000,4'hA,4'h5);
        apply("rst_mid_arith_op",          1,1,1,0,2'b11,4'b0001,4'h7,4'h3);
        apply("rst_mid_signed_add",        1,1,1,0,2'b11,4'b1011,4'h3,4'h2);
        apply("rst_mid_signed_sub",        1,1,1,0,2'b11,4'b1100,4'h7,4'h3);
        apply("rst_mid_compare",           1,1,1,0,2'b11,4'b1000,4'h5,4'h3);
        apply("rst_mid_inc_a",             1,1,1,0,2'b11,4'b0100,4'h5,4'h0);
        apply("rst_mid_dec_b",             1,1,1,0,2'b11,4'b0111,4'h0,4'h5);

        $display("\n---  CE=0 then CE=1 toggle ---");
        apply("ce_off_no_change",          0,1,0,0,2'b11,4'b0000,4'h3,4'h2);
        apply("ce_on_after_off",           0,1,1,0,2'b11,4'b0000,4'h3,4'h2);
        apply("ce_off_during_mul_setup",   0,1,0,0,2'b11,4'b1001,4'h2,4'h3);
        apply("ce_on_after_mul_off",       0,1,1,0,2'b11,4'b1001,4'h2,4'h3);

        $display("\n--- MODE toggle ---");
        apply("mode_0_and",                0,0,1,0,2'b11,4'b0000,4'hC,4'hA);
        apply("mode_1_add",                0,1,1,0,2'b11,4'b0000,4'hC,4'hA);
        apply("mode_0_or",                 0,0,1,0,2'b11,4'b0010,4'hC,4'hA);
        apply("mode_1_sub",                0,1,1,0,2'b11,4'b0001,4'hC,4'hA);
        apply("mode_0_xor",                0,0,1,0,2'b11,4'b0100,4'hC,4'hA);
        apply("mode_1_inc_a",              0,1,1,0,2'b11,4'b0100,4'hC,4'h0);


        $display("\n--- ADDITION (MODE=1, CMD=0000) ---");
        apply("ADD",   0, 1, 1, 0, 2'b11, 4'b0000, 4'b0011, 4'b0101);
        apply("ADD_HIGH",   0, 1, 1, 0, 2'b11, 4'b0000, 4'b1111, 4'b1111);
        apply("ADD_CARRY_GEN", 0,1,1,0, 2'b11, 4'b0000, 4'b1111, 4'b0001);
        apply("ADD_LOW",   0, 1, 1, 0, 2'b11, 4'b0000, 4'b0000, 4'b0000);
        apply("ADD_INP_VALID_01",   0, 1, 1, 0, 2'b01, 4'b0000, 4'b0011, 4'b0101);
        apply("ADD_INP_VALID_10",   0, 1, 1, 0, 2'b10, 4'b0000, 4'b0011, 4'b0101);
        apply("ADD_INP_VALID_00",   0, 1, 1, 0, 2'b00, 4'b0000, 4'b0011, 4'b0101);

        $display("\n--- SUBTRACTION (MODE=1, CMD=0001) ---");
        apply("SUB",                 0,1,1,0,2'b11,4'b0001,4'h7,4'h3);
        apply("SUB_OPB_0",           0,1,1,0,2'b11,4'b0001,4'hF,4'h0);
        apply("SUB_OPA_0",           0,1,1,0,2'b11,4'b0001,4'h0,4'h3);
        apply("SUB_OPB_HIGHER",      0,1,1,0,2'b11,4'b0001,4'h2,4'h5);
        apply("SUB_EQ_OP",           0,1,1,0,2'b11,4'b0001,4'h9,4'h9);
        apply("SUB_INP_VALID_01",    0,1,1,0,2'b01,4'b0001,4'h5,4'h3);
        apply("SUB_INP_VALID_10",    0,1,1,0,2'b10,4'b0001,4'h5,4'h3);
        apply("SUB_INP_VALID_00",    0,1,1,0,2'b00,4'b0001,4'h5,4'h3);


        $display("\n--- ADDITION WITH CIN (MODE=1, CMD=0010) ---");
        apply("addition_cin",                0,1,1,1,2'b11,4'b0010,4'h3,4'h2);
        apply("addition_cin_low",            0,1,1,1,2'b11,4'b0010,4'h0,4'h0);
        apply("addition_cin_high",           0,1,1,1,2'b11,4'b0010,4'hF,4'hF);
        apply("addition_cin_OPB_0",          0,1,1,0,2'b11,4'b0010,4'hF,4'h0);
        apply("addition_cin__INP_VALID_01",  0,1,1,1,2'b01,4'b0010,4'h3,4'h2);
        apply("addition_cin_INP_VALID_10",   0,1,1,1,2'b10,4'b0010,4'h3,4'h2);
        apply("addition_cin_INP_VALID_00",   0,1,1,1,2'b00,4'b0010,4'h3,4'h2);


        $display("\n--- SUBTRACT WITH CIN (MODE=1, CMD=0011) ---");
        apply("subtraction_cin",             0,1,1,1,2'b11,4'b0011,4'h7,4'h3);
        apply("subtraction_cin_OPB_0",       0,1,1,1,2'b11,4'b0011,4'h5,4'h0);
        apply("subtraction_cin_OPA_0",       0,1,1,1,2'b11,4'b0011,4'h0,4'h0);
        apply("subtraction_cin__INP_VALID_01",0,1,1,1,2'b01,4'b0011,4'h7,4'h3);
        apply("subtraction_cin_INP_VALID_10",0,1,1,1,2'b10,4'b0011,4'h7,4'h3);
        apply("subtraction_cin_INP_VALID_00",0,1,1,1,2'b00,4'b0011,4'h7,4'h3);

        $display("\n--- INCREMENT A (MODE=1, CMD=0100) ---");
        apply("inc_a",                       0,1,1,0,2'b01,4'b0100,4'h5,4'h0);
        apply("inc_a_max",                   0,1,1,0,2'b01,4'b0100,4'hF,4'h0);
        apply("inc_a__INP_VALID_11",         0,1,1,0,2'b11,4'b0100,4'h5,4'h3);
        apply("inc_a_INP_VALID_10",          0,1,1,0,2'b10,4'b0100,4'h5,4'h3);
        apply("inc_a_INP_VALID_00",          0,1,1,0,2'b00,4'b0100,4'h5,4'h0);

        $display("\n--- DECREMENT A (MODE=1, CMD=0101) ---");
        apply("dec_a",                       0,1,1,0,2'b01,4'b0101,4'h5,4'h0);
        apply("dec_a_min",                   0,1,1,0,2'b01,4'b0101,4'h0,4'h0);
        apply("dec_a__INP_VALID_11",         0,1,1,0,2'b11,4'b0101,4'h5,4'h3);
        apply("dec_a_INP_VALID_10",          0,1,1,0,2'b10,4'b0101,4'h5,4'h3);
        apply("dec_a_INP_VALID_00",          0,1,1,0,2'b00,4'b0101,4'h5,4'h0);

        $display("\n--- INCREMENT B (MODE=1, CMD=0110) ---");
        apply("Inc_b",                       0,1,1,0,2'b10,4'b0110,4'h0,4'h5);
        apply("inc_b_max",                   0,1,1,0,2'b10,4'b0110,4'h0,4'hF);
        apply("inc_b_INP_VALID_11",          0,1,1,0,2'b11,4'b0110,4'h3,4'h5);
        apply("inc_b_INP_VALID_01",          0,1,1,0,2'b01,4'b0110,4'h3,4'h5);
        apply("inc_b_INP_VALID_00",          0,1,1,0,2'b00,4'b0110,4'h0,4'h5);

        $display("\n--- DECREMENT B (MODE=1, CMD=0111) ---");
        apply("dec_b",                       0,1,1,0,2'b10,4'b0111,4'h0,4'h5);
        apply("dec_b_min",                   0,1,1,0,2'b10,4'b0111,4'h0,4'h0);
        apply("dec_b_INP_VALID_11",          0,1,1,0,2'b11,4'b0111,4'h3,4'h5);
        apply("dec_b_INP_VALID_01",          0,1,1,0,2'b01,4'b0111,4'h3,4'h5);
        apply("dec_b_INP_VALID_00",          0,1,1,0,2'b00,4'b0111,4'h0,4'h5);

        $display("\n--- COMPARE (MODE=1, CMD=1000) ---");
        apply("compare_greater",             0,1,1,0,2'b11,4'b1000,4'h9,4'h3);
        apply("compare_lesser",              0,1,1,0,2'b11,4'b1000,4'h3,4'h9);
        apply("compare_equal",               0,1,1,0,2'b11,4'b1000,4'h5,4'h5);
        apply("compare_both_zero",           0,1,1,0,2'b11,4'b1000,4'h0,4'h0);
        apply("compare_max_values_equal",    0,1,1,0,2'b11,4'b1000,4'hF,4'hF);
        apply("compare_opa_max_opb_zero",    0,1,1,0,2'b11,4'b1000,4'hF,4'h0);
        apply("compare_INP_VALID_01",        0,1,1,0,2'b01,4'b1000,4'h5,4'h3);
        apply("compare_INP_VALID_10",        0,1,1,0,2'b10,4'b1000,4'h5,4'h3);
        apply("compare_INP_VALID_00",        0,1,1,0,2'b00,4'b1000,4'h5,4'h3);
        apply("cmp_opa_0_opb_f",           0,1,1,0,2'b11,4'b1000,4'h0,4'hF);
        apply("cmp_opa_f_opb_0",           0,1,1,0,2'b11,4'b1000,4'hF,4'h0);
        apply("cmp_opa_1_opb_0",           0,1,1,0,2'b11,4'b1000,4'h1,4'h0);
        apply("cmp_opa_0_opb_1",           0,1,1,0,2'b11,4'b1000,4'h0,4'h1);


        $display("\n--- MUL INC (M0DE=1, CMD=1001) ---");
        apply("Mul_inc_1",                  0,1,1,0,2'b11,4'b1001,4'h2,4'h3);
        apply("Mul_inc_high",               0,1,1,0,2'b11,4'b1001,4'hF,4'hF);
        apply("Mul_inc_low",                0,1,1,0,2'b11,4'b1001,4'h0,4'h0);
        apply("Mul_inc_opa_zero_opb_value", 0,1,1,0,2'b11,4'b1001,4'h0,4'hF);
        apply("Mul_inc_overflow_check",     0,1,1,0,2'b11,4'b1001,4'hF,4'hF);
        apply("Mul_inc_INP_VALID_01",       0,1,1,0,2'b01,4'b1001,4'h3,4'h2);
        apply("Mul_inc_INP_VALID_10",       0,1,1,0,2'b10,4'b1001,4'h3,4'h2);
        apply("Mul_inc_INP_VALID_00",       0,1,1,0,2'b00,4'b1001,4'h3,4'h2);
        apply("Mul_inc_after_3cycles",      0,1,1,0,2'b11,4'b1001,4'h2,4'h3);


        $display("\n--- MUL SHIFT (MODE=1, CMD=1010) ---");
        apply("mul_sft",                 0,1,1,0,2'b11,4'b1010,4'h3,4'h4);
        apply("mul_sft_OPA_1",           0,1,1,0,2'b11,4'b1010,4'h8,4'h2);
        apply("mul_sft_opa_zero",        0,1,1,0,2'b11,4'b1010,4'h0,4'h5);
        apply("mul_sft_msb_set",         0,1,1,0,2'b11,4'b1010,4'h8,4'h2);
        apply("mul_sft_normal",          0,1,1,0,2'b11,4'b1010,4'h3,4'h4);
        apply("mul_sft_INP_VALID_01",    0,1,1,0,2'b01,4'b1010,4'h3,4'h2);
        apply("mul_sft_INP_VALID_10",    0,1,1,0,2'b10,4'b1010,4'h3,4'h2);
        apply("mul_sft_INP_VALID_00",    0,1,1,0,2'b00,4'b1010,4'h3,4'h2);
        apply("mul_after_3_cycles_1010", 0,1,1,0,2'b11,4'b1010,4'h3,4'h4);


        $display("\n--- SIGNED ADD (MODE=1, CMD=1011) ---");
        apply("signed_add",                  0,1,1,0,2'b11,4'b1011,4'h3,4'h2);
        apply("signed_add_oflow",            0,1,1,0,2'b11,4'b1011,4'h7,4'h7);
        apply("signed_add_pos_neg",          0,1,1,0,2'b11,4'b1011,4'h3,4'h8);
        apply("signed_add_neg_neg",          0,1,1,0,2'b11,4'b1011,4'h9,4'h9);
        apply("signed_add_zero_result",      0,1,1,0,2'b11,4'b1011,4'h8,4'h8);
        apply("signed_add_gel_check",        0,1,1,0,2'b11,4'b1011,4'h5,4'h7);
        apply("signed_add_INP_VALID_01",     0,1,1,0,2'b01,4'b1011,4'h3,4'h2);
        apply("signed_add_INP_VALID_10",     0,1,1,0,2'b10,4'b1011,4'h3,4'h2);
        apply("signed_add_INP_VALID_00",     0,1,1,0,2'b00,4'b1011,4'h3,4'h2);

        $display("\n--- SIGNED SUBTRACT (MODE=1, CMD=1100) ---");
        apply("signed_sub",                  0,1,1,0,2'b11,4'b1100,4'h7,4'h3);
        apply("signed_sub_oflow_p_n",        0,1,1,0,2'b11,4'b1100,4'h7,4'h9);
        apply("signed_sub_oflow_n_p",        0,1,1,0,2'b11,4'b1100,4'h8,4'h7);
        apply("signed_sub_zero_result",      0,1,1,0,2'b11,4'b1100,4'h5,4'h5);
        apply("signed_sub_gel_check_less",   0,1,1,0,2'b11,4'b1100,4'h3,4'h5);
        apply("signed_sub_INP_VALID_01",     0,1,1,0,2'b01,4'b1100,4'h7,4'h3);
        apply("signed_sub_INP_VALID_10",     0,1,1,0,2'b10,4'b1100,4'h7,4'h3);
        apply("signed_sub_INP_VALID_00",     0,1,1,0,2'b00,4'b1100,4'h7,4'h3);

        $display("\n--- LOGICAL AND (MODE=0, CMD=0000) ---");
        apply("and",                         0,0,1,0,2'b11,4'b0000,4'hA,4'h6);
        apply("and_all_zeros",               0,0,1,0,2'b11,4'b0000,4'h0,4'h0);
        apply("and_all_ones",                0,0,1,0,2'b11,4'b0000,4'hF,4'hF);
        apply("and_complementary",           0,0,1,0,2'b11,4'b0000,4'hA,4'h5);
        apply("and_INP_VALID_00",            0,0,1,0,2'b00,4'b0000,4'hA,4'h5);
        apply("and_INP_VALID_01",            0,0,1,0,2'b01,4'b0000,4'hA,4'h5);
        apply("and_INP_VALID_10",           0,0,1,0,2'b10,4'b0000,4'hA,4'h5);





        $display("\n--- LOGICAL NAND (MODE=0, CMD=0001) ---");
        apply("nand",                        0,0,1,0,2'b11,4'b0001,4'hA,4'h6);
        apply("nand_high",                   0,0,1,0,2'b11,4'b0001,4'hF,4'hF);
        apply("nand_INP_VALID_00",            0,0,1,0,2'b00,4'b0001,4'hA,4'h5);
        apply("nand_INP_VALID_01",            0,0,1,0,2'b01,4'b0001,4'hA,4'h5);
        apply("nand_INP_VALID_10",           0,0,1,0,2'b10,4'b0001,4'hA,4'h5);




        $display("\n--- LOGICAL OR (MODE=0, CMD=0010) ---");
        apply("or",                          0,0,1,0,2'b11,4'b0010,4'hA,4'h5);
        apply("or_all_zeros",                0,0,1,0,2'b11,4'b0010,4'h0,4'h0);
        apply("or_INP_VALID_00",            0,0,1,0,2'b00,4'b0010,4'hA,4'h5);
        apply("or_INP_VALID_01",            0,0,1,0,2'b01,4'b0010,4'hA,4'h5);
        apply("or_INP_VALID_10",           0,0,1,0,2'b10,4'b0010,4'hA,4'h5);




        $display("\n--- LOGICAL NOR (MODE=0, CMD=0011) ---");
        apply("nor",                         0,0,1,0,2'b11,4'b0011,4'hA,4'h5);
        apply("nor_INP_VALID_00",            0,0,1,0,2'b00,4'b0011,4'hA,4'h5);
        apply("nor_INP_VALID_01",            0,0,1,0,2'b01,4'b0011,4'hA,4'h5);
        apply("nor_INP_VALID_10",           0,0,1,0,2'b10,4'b0011,4'hA,4'h5);


        $display("\n--- LOGICAL XOR (MODE=0, CMD=0100) ---");
        apply("xor",                         0,0,1,0,2'b11,4'b0100,4'hA,4'h5);
        apply("xor_same_values",             0,0,1,0,2'b11,4'b0100,4'h5,4'h5);
        apply("xor_INP_VALID_00",            0,0,1,0,2'b00,4'b0100,4'hA,4'h5);
        apply("xor_INP_VALID_01",            0,0,1,0,2'b01,4'b0100,4'hA,4'h5);
        apply("xor_INP_VALID_10",           0,0,1,0,2'b10,4'b0100,4'hA,4'h5);


        $display("\n--- LOGICAL XNOR (MODE=0, CMD=0101) ---");
        apply("xnor",                        0,0,1,0,2'b11,4'b0101,4'hA,4'h5);
        apply("xnor_diff_values",            0,0,1,0,2'b11,4'b0101,4'hA,4'h5);
        apply("xnor_INP_VALID_00",            0,0,1,0,2'b00,4'b0101,4'hA,4'h5);
        apply("xnor_INP_VALID_01",            0,0,1,0,2'b01,4'b0101,4'hA,4'h5);
        apply("xnor_INP_VALID_10",           0,0,1,0,2'b10,4'b0101,4'hA,4'h5);




        $display("\n--- LOGICAL NOT A (MODE=0, CMD=0110) ---");
        apply("not_a",                       0,0,1,0,2'b11,4'b0110,4'hA,4'h0);
        apply("not_a_all_zeros",             0,0,1,0,2'b01,4'b0110,4'h0,4'h0);
        apply("not_a_all_ones",              0,0,1,0,2'b01,4'b0110,4'hF,4'h0);
        apply("not_INP_VALID_00",            0,0,1,0,2'b00,4'b0110,4'hF,4'h0);
        apply("not_INP_VALID_10",            0,0,1,0,2'b10,4'b0110,4'hF,4'h0);


        $display("\n--- LOGICAL NOT B (MODE=0, CMD=0111) ---");
        apply("not_b",                       0,0,1,0,2'b11,4'b0111,4'h0,4'hA);
        apply("not_b_all_zeros",             0,0,1,0,2'b10,4'b0111,4'h0,4'h0);
        apply("not_b_all_ones",              0,0,1,0,2'b10,4'b0111,4'h0,4'hF);
        apply("not_INP_VALID_00",            0,0,1,0,2'b00,4'b0111,4'h0,4'hF);
        apply("not_INP_VALID_01",            0,0,1,0,2'b01,4'b0111,4'h0,4'hF);


        $display("\n--- SHIFT RIGHT A (MODE=0, CMD=1000) ---");
        apply("shr1_a",                      0,0,1,0,2'b11,4'b1000,4'hA,4'h0);
        apply("shr1_a_msb_check",            0,0,1,0,2'b01,4'b1000,4'h8,4'h0);
        apply("shr1_INV_INP",                0,0,1,0,2'b10,4'b1000,4'hC,4'h0);
        apply("shr1_INV_INP",                0,0,1,0,2'b00,4'b1000,4'hC,4'h0);
        apply("shr1_INV_CMD",                0,0,1,0,2'b11,4'b1110,4'hA,4'h0);
        apply("shr1_INV_CMD",                0,0,1,0,2'b11,4'b1111,4'hA,4'h0);


        $display("\n--- SHIFT LEFT A (MODE=0, CMD=1001) ---");
        apply("shl1_a",                      0,0,1,0,2'b11,4'b1001,4'hA,4'h0);
        apply("shl_a_lsb_check",             0,0,1,0,2'b01,4'b1001,4'h1,4'h0);
        apply("shl1_a_lsb_check",            0,0,1,0,2'b01,4'b1001,4'h1,4'h0);
        apply("shl1_a_msb_overflow",         0,0,1,0,2'b01,4'b1001,4'hF,4'h0);
        apply("shl1_INV_INP",                0,0,1,0,2'b10,4'b1001,4'hC,4'h0);
        apply("shl1_INV_INP",                0,0,1,0,2'b00,4'b1001,4'hC,4'h0);


        $display("\n--- SHIFT RIGHT B (MODE=0, CMD=1010) ---");
        apply("shr1_b",                      0,0,1,0,2'b11,4'b1010,4'h0,4'hA);
        apply("shr1_b_lsb_check",            0,0,1,0,2'b10,4'b1010,4'h0,4'h9);
        apply("shr1_INV_INP",                0,0,1,0,2'b01,4'b1010,4'h0,4'hC);
        apply("shr1_INV_INP",                0,0,1,0,2'b00,4'b1010,4'h0,4'hF);

        $display("\n--- SHIFT LEFT B (MODE=0, CMD=1011) ---");
        apply("shl1_b",                      0,0,1,0,2'b11,4'b1011,4'h0,4'hA);
        apply("shl1_b_max",                  0,0,1,0,2'b10,4'b1011,4'h0,4'hF);
        apply("shl1_INV_INP",                0,0,1,0,2'b01,4'b1011,4'h0,4'hD);
        apply("shl1_INV_INP",                0,0,1,0,2'b00,4'b1011,4'h0,4'hC);


        $display("\n--- ROTATE LEFT A (MODE=0, CMD=1100) ---");
        apply("rol_a_0",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h0);
        apply("rol_a_1",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h1);
        apply("rol_a_2",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h2);
        apply("rol_a_3",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h3);
        apply("rol_a_4",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h4);
        apply("rol_a_5",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h5);
        apply("rol_a_6",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h6);
        apply("rol_a_7",                     0,0,1,0,2'b11,4'b1100,4'hB,4'h7);
        apply("rol_err_opb_bit4_set",        0,0,1,0,2'b11,4'b1100,4'hA,4'b1001);
        apply("rol_err_opb_bit5_set",        0,0,1,0,2'b11,4'b1100,4'hA,4'b1010);
        apply("rol_err_opb_bit6_set",        0,0,1,0,2'b11,4'b1100,4'hA,4'b1100);
        apply("rol_err_opb_bit7_set",        0,0,1,0,2'b11,4'b1100,4'hA,4'b1000);
        apply("rol_INV_INPUT_01",            0,0,1,0,2'b01,4'b1100,4'hA,4'h1);
        apply("rol_INV_INPUT_10",            0,0,1,0,2'b10,4'b1100,4'hA,4'h1);
        apply("rol_INV_INPUT_00",            0,0,1,0,2'b00,4'b1100,4'hA,4'h1);
        apply("rol_err_opb_multiple_upper_bits",0,0,1,0,2'b11,4'b1100,4'hA,4'hF);

        $display("\n--- ROTATE RIGHT A (MODE=0, CMD=1101) ---");
        apply("ror_a_0",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h0);
        apply("ror_a_1",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h1);
        apply("ror_a_2",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h2);
        apply("ror_a_3",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h3);
        apply("ror_a_4",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h4);
        apply("ror_a_5",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h5);
        apply("ror_a_6",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h6);
        apply("ror_a_7",                     0,0,1,0,2'b11,4'b1101,4'hB,4'h7);
        apply("ror_err_opb_bit4_set",        0,0,1,0,2'b11,4'b1101,4'hA,4'b1001);
        apply("ror_err_opb_bit5_set",        0,0,1,0,2'b11,4'b1101,4'hA,4'b1010);
        apply("ror_err_opb_bit6_set",        0,0,1,0,2'b11,4'b1101,4'hA,4'b1100);
        apply("ror_err_opb_bit7_set",        0,0,1,0,2'b11,4'b1101,4'hA,4'b1000);
        apply("ror_err_opb_upper_bits",      0,0,1,0,2'b11,4'b1101,4'hA,4'b1010);
        apply("ror_err_all_upper_bits",      0,0,1,0,2'b11,4'b1101,4'hA,4'hF);
        apply("ror_INV_INPUT_01",            0,0,1,0,2'b01,4'b1101,4'hA,4'h1);
        apply("ror_INV_INPUT_10",            0,0,1,0,2'b10,4'b1101,4'hA,4'h1);
        apply("ror_INV_INPUT_00",            0,0,1,0,2'b00,4'b1101,4'hA,4'h1);
    $display("===================================\n");
    $display("  RESULTS:  PASS=%0d  FAIL=%0d", pass_count, fail_count);
    $display("===================================\n");

    $finish;
  end

  initial begin
    #50000;
    $display("TIMEOUT: simulation exceeded 50000 ns");
    $finish;
  end

initial begin
$dumpfile("ALU_OUT.vcd");
$dumpvars(0, alu_tb);
end
endmodule
