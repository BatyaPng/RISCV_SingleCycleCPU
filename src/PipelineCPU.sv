`include "PipelineCPU/RegStage.sv"
`include "PipelineCPU/ALUStage.sv"
`include "PipelineCPU/DataStage.sv"


module PipelineCPU
(
    input wire clk,
    input wire reset,

    inout wire [31:0] MemData,
    output wire ReadMemEN,
    output wire WriteMemEN,
    output wire [31:0] MemoryAdr, 

    output wire [4:0] R1_adr,
    output wire [4:0] R2_adr,
    output wire [4:0] DR_adr,

    input wire [31:0] R1,
    input wire [31:0] R2,
    output wire [31:0] DR,

    output wire RegWEN
);

// Conf_solver

assign RS_reset = reset;
assign ALU_reset = reset;
assign DS_reset = reset |  MemAssert;

//Instr_stage


// Mem Asert
assign RS_EN = ~MemAssert;
assign ALU_EN = ~MemAssert;
assign DS_EN = ~MemAssert;

assign MemData = (MemWrite)? ALU_WriteData: 32'bz; 

assign MemoryAdr = (MemAssert)? ({1'b1}, 31{1'b0}) |  ALUResData: PC;

// Reg_wr_stage

reg [31:0] PC;

always @(posedge clk) begin
    if(reset)
        PC <= 0;
    else if(~MemAssert) begin // I don't sure
        if(ALU_PCSrc)
            PC <= ALU_PCTarget;
        else 
            PC <= DS_PC_plus_4;
    end
end

assign DR_adr = DS_DR_num;
assign RegWEN = DS_RegWrite;

mux3 ResultMux (
    .d0(DS_ALUResData),
    .d1(MemData),
    .d2(DS_PC_plus_4),

    .s(DS_ResultSrc),

    .y(DR)
);



// Reg Stage

wire RS_reset;
wire RS_EN;

wire [31:0] Instr;
wire [31:0] w_PC;
wire [31:0] PC_plus_4;

RegStage RegStage (
    .clk(clk),
    .reset(RS_reset),

    .EN(RS_EN),

    .Instr(Instr),
    .w_PC(w_PC),
    .w_PC_plus_4(PC_plus_4),

    .w_R_1_num(R1_adr),
    .w_R_2_num(R2_adr),
    .w_R_1(R1),
    .w_R_2(R2),

    .R_1(RS_R1),
    .R_2(RS_R2),
    .R_1_num(RS_R_1_num),
    .R_2_num(RS_R_2_num),
    .DR_num(RS_DR_num),

    .w_DR_num(RS_DR_num),

    .ImmExt(RS_ImmExt),

    .PC(RS_PC),
    .PC_plus_4(RS_PC_plus_4),

    .ResultSrc(RS_ResultSrc),
    .MemWrite(RS_MemWrite),
    .ALUSrc(RS_ALUSrc),
    .RegWrite(RS_RegWrite),
    .Jump(RS_Jump),
    .Branch(RS_Branch),
    .ALUControl(RS_ALUControl),
    .MemRead(RS_MemRead)
);

wire [31:0] RS_R1;
wire [31:0] RS_R2;
wire [4:0] RS_R_1_num;
wire [4:0] RS_R_2_num;
wire [4:0] RS_DR_num;

wire [4:0] RS_DR_num;

wire [31:0] RS_ImmExt;

wire [31:0] RS_PC;
wire [31:0] RS_PC_plus_4;

wire [1:0] RS_ResultSrc;
wire RS_MemWrite;
wire RS_ALUSrc;
wire RS_RegWrite;
wire RS_Jump;
wire RS_Branch;
wire [3:0] RS_ALUControl;
wire RS_MemRead;

// ALU Stage
wire ALU_reset;
wire ALU_EN;

wire [31:0] ALUResData;
wire [31:0] DataReadData;

wire [1:0] R_1_solve;
wire [1:0] R_2_solve;

ALUStage ALUStage(
    .reset(ALU_reset),
    .clk(clk),

    .EN(ALU_EN),

    .w_PC(RS_PC),
    .w_PC_plus_4(RS_PC_plus_4),

    .w_R_1(RS_R1),
    .w_R_2(RS_R2),
    .w_ImmExt(RS_ImmExt),

    .w_R_1_num(RS_R_1_num),
    .w_R_2_num(RS_R_2_num),
    .w_DR_num(RS_DR_num),

    .ALUResData(ALUResData),
    .DataReadData(DataReadData),

    .R_1_solve(R_1_solve),
    .R_2_solve(R_2_solve),

    .DR(ALUResData),
    .DR_num(ALU_DR_num),

    .WriteData(ALU_WriteData),

    .PC(ALU_PC),
    .PC_plus_4(ALU_PC_plus_4),
    .PCTarget(ALU_PCTarget),
    .PCSrc(ALU_PCSrc),

    .w_ResultSrc(RS_ResultSrc),
    .w_MemWrite(RS_MemWrite),
    .w_ALUSrc(RS_ALUSrc),
    .w_RegWrite(RS_RegWrite),
    .w_Jump(RS_Jump),
    .w_Branch(RS_Branch),
    .w_ALUControl(RS_ALUControl),
    .w_MemRead(RS_MemRead),

    .ResultSrc(ALU_ResultSrc),
    .MemWrite(ALU_MemWrite),
    .RegWrite(ALU_RegWrite),
    .MemRead(ALU_MemRead),
    .ALUControl(ALU_ALUControl)
);

wire [4:0] ALU_DR_num;
wire [31:0] ALU_WriteData;

wire [31:0] ALU_PC;
wire [31:0] ALU_PC_plus_4;
wire [31:0] ALU_PCTarget;
wire ALU_PCSrc;

wire [1:0] ALU_ResultSrc;
wire ALU_MemWrite;
wire ALU_RegWrite;
wire ALU_MemRead;
wire [2:0] ALU_ALUControl;

// DataStage
wire DS_reset;
wire DS_EN;

DataStage DataStage(
    .reset(DS_reset),
    .clk(clk),

    .EN(DS_EN),

    .w_DR_num(ALU_DR_num),
    .w_PC_plus_4(ALU_PC_plus_4),

    .w_ALUResData(ALUResData),
    
    .MemAssert(MemAssert),

    .w_ReadData(MemData),
    .ReadData(DS_ReadData),

    .ALUResData(DS_ALUResData),
    .PC_plus_4(DS_ALUResData),
    .DR_num(DS_DR_num),

    .w_ResultSrc(ALU_ResultSrc),
    .w_MemWrite(ALU_MemWrite),
    .w_RegWrite(ALU_RegWrite),
    .w_MemRead(ALU_MemRead),

    .ResultSrc(DS_ResultSrc),
    .RegWrite(DS_RegWrite)
);

wire MemAssert;

wire [31:0] DS_ReadData;
wire [31:0] DS_ALUResData;
wire [31:0] DS_PC_plus_4;
wire [4:0] DS_DR_num;

wire [1:0] DS_ResultSrc;
wire DS_RegWrite;

assign WriteMemEN = ALU_MemWrite;
assign ReadMemEN = ~ALU_MemWrite;



endmodule