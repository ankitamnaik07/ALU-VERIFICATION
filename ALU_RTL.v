module alu_reference_model #(parameter WIDTH = 8,parameter cmd_width = 4)(
    input [WIDTH-1:0]OPA, OPB,
    input CE, CIN, MODE, RST, CLK,
    input [cmd_width-1:0]CMD,
    input [1:0] INP_VALID,
    output reg [2*WIDTH-1:0] RES,
    output reg COUT, OFLOW, G, E, L, ERR);

    reg signed [WIDTH-1:0] OPA_s, OPB_s;
    reg signed [WIDTH:0] RES_s;
    reg cnt;
    reg [7:0] rot_tmp;
    integer rot_amt;

    task set_z;
        begin
            RES <= 'bz;
            COUT <= 1'bz;
            OFLOW <= 1'bz;
            G <= 1'bz;
            E <= 1'bz;
            L <= 1'bz;
            ERR <= 1'bz;
        end
    endtask

    always @(posedge CLK) begin

        if (CE) begin

            if (RST) begin
                set_z;

            end else if (MODE) begin
                set_z;
 case (CMD)

                    4'b0000: begin
                        if (INP_VALID == 2'b11) begin
                            RES  <= OPA + OPB;
                            COUT <= (OPA + OPB+ 9'b0) >> WIDTH;
                        end
                        else ERR <= 1;
                    end

                    4'b0001: begin
                        if (INP_VALID == 2'b11) begin
                            OFLOW <= (OPA < OPB);
                            RES   <= OPA - OPB;
                        end
                       else ERR <= 1;
                    end

                    4'b0010: begin
                        if (INP_VALID == 2'b11) begin
                            RES  <= OPA + OPB + CIN;
                            COUT <= (OPA + OPB + CIN+ 9'b0) >> WIDTH;
                        end
                        else ERR <=1;
                    end

                    4'b0011: begin
                        if (INP_VALID == 2'b11) begin
                            OFLOW <= (OPA < (OPB + CIN));
                            RES   <= OPA - OPB - CIN;
                        end
                        else ERR <= 1;
                    end


                    4'b0100: begin
                        if (INP_VALID[0]) begin
                            RES <= OPA + 1;
                        end
                       else ERR <= 1;
                    end
                    4'b0101: begin
                        if (INP_VALID[0]) begin
                            RES <= OPA - 1;
                        end
                        else ERR <= 1;
                    end

                    4'b0110: begin
                        if (INP_VALID[1]) begin
                            RES <= OPB + 1;
                        end
                        else ERR <= 1;
                    end

                    4'b0111: begin
                        if (INP_VALID[1]) begin
                            RES <= OPB - 1;
                        end
                    end

                    4'b1000: begin
                        if (INP_VALID == 2'b11) begin
                            RES <= 'bz;
                            if (OPA == OPB) begin
                                E <= 1'b1; G <= 1'bz; L <= 1'bz;
                            end else if (OPA > OPB) begin
                                E <= 1'bz; G <= 1'b1; L <= 1'bz;
                            end else begin
                                E <= 1'bz; G <= 1'bz; L <= 1'b1;
                            end
                        end
                        else ERR <= 1;
                    end

                    4'b1001: begin
                        if (INP_VALID == 2'b11) begin
                                if(cnt == 0)begin
                                       OPA_s <= OPA;
                                       OPB_s <= OPB;
                                       RES <= 0;
                                       cnt <= cnt + 1;
                               end
                               else if (cnt < 2)begin
                                        cnt <= cnt + 1;
                                        RES <= 0;
                                        cnt<= cnt +1;
                                end
                                else if(cnt >= 2)begin
                                        RES <= ((OPA_s + 1) * (OPB_s + 1)) & {(WIDTH+1){1'b1}};
                                        cnt <=0;
                                end
                        end
                       
else ERR<= 1;
                    end

                    4'b1010: begin
                        if (INP_VALID == 2'b11) begin
                                OPA_s <= OPA;
                                       OPB_s <= OPB;
                                       RES <= 0;
                                       cnt <= cnt + 1;
                               end
                               else if (cnt < 20)begin
                                        cnt <= cnt + 1;
                                        RES <= 0;
                                        cnt<= cnt +1;
                                end
                                else if(cnt >= 2)begin

                                        RES <= ({1'b0, OPA_s[WIDTH-2:0]} * OPB_s) & {(WIDTH+1){1'b1}};
                                        cnt <= 0;
                        end
else ERR <= 1;
                    end
 4'b1011: begin
                        if (INP_VALID == 2'b11) begin
                            OPA_s = $signed(OPA);
                            OPB_s = $signed(OPB);
                            RES_s = OPA_s + OPB_s;
                            RES   <= RES_s;
                            COUT  <= RES_s[WIDTH];
                            OFLOW <= (~OPA_s[WIDTH-1] & ~OPB_s[WIDTH-1] &  RES_s[WIDTH-1]) |
                                     ( OPA_s[WIDTH-1] &  OPB_s[WIDTH-1] & ~RES_s[WIDTH-1]);
                            if      (OPA_s == OPB_s) begin E <= 1'b1; G <= 1'bz; L <= 1'bz; end
                            else if (OPA_s >  OPB_s) begin E <= 1'bz; G <= 1'b1; L <= 1'bz; end
                            else                     begin E <= 1'bz; G <= 1'bz; L <= 1'b1; end
                        end
else ERR <= 1;
                    end

                    4'b1100: begin
                        if (INP_VALID == 2'b11) begin
                            OPA_s = $signed(OPA);
                            OPB_s = $signed(OPB);
                            RES_s = OPA_s - OPB_s;
                            RES   <= RES_s;
                            COUT  <= RES_s[WIDTH];
                            OFLOW <= (~OPA_s[WIDTH-1] &  OPB_s[WIDTH-1] &  RES_s[WIDTH-1]) |
                                     ( OPA_s[WIDTH-1] & ~OPB_s[WIDTH-1] & ~RES_s[WIDTH-1]);
                            if      (OPA_s == OPB_s) begin E <= 1'b1; G <= 1'bz; L <= 1'bz; end
                            else if (OPA_s >  OPB_s) begin E <= 1'bz; G <= 1'b1; L <= 1'bz; end
                            else                     begin E <= 1'bz; G <= 1'bz; L <= 1'b1; end
                        end
else ERR <= 1;
                    end

                    default: set_z;

                endcase

            end else begin
                set_z;
 case (CMD)
                    4'b0000: RES <= {1'b0, OPA & OPB};
                    4'b0001: RES <= {1'b0, ~(OPA & OPB)};
                    4'b0010: RES <= {1'b0, OPA | OPB};
                    4'b0011: RES <= {1'b0, ~(OPA | OPB)};
                    4'b0100: RES <= {1'b0, OPA ^ OPB};
                    4'b0101: RES <= {1'b0, ~(OPA ^ OPB)};
                    4'b0110: RES <= {1'b0, ~OPA};
                    4'b0111: RES <= {1'b0, ~OPB};
                    4'b1000: RES <= {1'b0, OPA >> 1};
                    4'b1001: RES <= {1'b0, OPA << 1};
                    4'b1010: RES <= {1'b0, OPB >> 1};
                    4'b1011: RES <= {1'b0, OPB << 1};

                    4'b1100: begin
                        rot_amt = OPB[2:0];
                        case (rot_amt)
                            3'b000: rot_tmp = OPA;
                            3'b001: rot_tmp = {OPA[6:0], OPA[7]};
                            3'b010: rot_tmp = {OPA[5:0], OPA[7:6]};
                            3'b011: rot_tmp = {OPA[4:0], OPA[7:5]};
                            3'b100: rot_tmp = {OPA[3:0], OPA[7:4]};
                            3'b101: rot_tmp = {OPA[2:0], OPA[7:3]};
                            3'b110: rot_tmp = {OPA[1:0], OPA[7:2]};
                            3'b111: rot_tmp = {OPA[0],   OPA[7:1]};
                            default: rot_tmp = OPA;
                        endcase
                        RES <= {1'b0, rot_tmp};
                        ERR <= (OPB[4] | OPB[5] | OPB[6] | OPB[7]);
                    end
4'b1101: begin
                        rot_amt = OPB[2:0];
                        case (rot_amt)
                            3'd0: rot_tmp = OPA;
                            3'd1: rot_tmp = {OPA[0], OPA[7:1]};
                            3'd2: rot_tmp = {OPA[1:0], OPA[7:2]};
                            3'd3: rot_tmp = {OPA[2:0], OPA[7:3]};
                            3'd4: rot_tmp = {OPA[3:0], OPA[7:4]};
                            3'd5: rot_tmp = {OPA[4:0], OPA[7:5]};
                            3'd6: rot_tmp = {OPA[5:0], OPA[7:6]};
                            3'd7: rot_tmp = {OPA[6:0], OPA[7]};
                            default: rot_tmp = OPA;
                        endcase
                        RES <= {1'b0, rot_tmp};
                        ERR <= (OPB[4] | OPB[5] | OPB[6] | OPB[7]);
                    end

                    default: set_z;

                endcase

            end
        end
    end

endmodule

