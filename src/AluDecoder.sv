module aludec(input opb5,
              input [2:0] funct3,
              input funct7b5,
              input [1:0] ALUOp,
              
              output [2:0] ALUControl
);

wire RtypeSub;

assign RtypeSub = funct7b5 & opb5;

always_comb begin
    case (ALUOp)
        2'b00: ALUControl = 3'b000;                     // addition
        2'b01: ALUControl = 3'b001;                     // subtraction
        default: case(funct3)                           // type R or I
                    3'b000: if (RtypeSub)
                                ALUControl = 3'b001;    // sub
                            else
                                ALUControl = 3'b000;    // add, addi
                    3'b010: ALUControl = 3'b101;        // slt, slti
                    3'b110: ALUControl = 3'b011;        // or, ori
                    3'b111: ALUControl = 3'b010;        // and, andi
                    default: ALUControl = 3'bxxx;       // ub
                 endcase
    endcase
end

endmodule