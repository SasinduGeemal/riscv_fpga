`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yasas Seneviratne
// 
// Create Date: 08/12/2016 10:09:38 AM
// Design Name: 
// Module Name: PIPELINE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PIPELINE(
    input           CLK,
    input           CACHE_READY,
    input   [31:0]  PC_IF_ID, //IF out to ID in
    input   [31:0]  INS_IF_ID,
    
    output          BRANCH_TAKEN,
    output  [31:0]  BRANCH_ADDRESS,
    output  [31:0]  ALU,
    output          COMPAR,
    output          PIPELINE_STALL
    );
    
    //Cache parameters and variables
    
    
    
    
    
    //Instruction Decode stage
    
   // wire [31:0] PC_ID_EX_WIRE; 
    wire [4:0]  RD_ID_EX_WIRE;
    wire [31:0] RS1_ID_EX_WIRE;
    wire [31:0] RS2_ID_EX_WIRE;
    wire [31:0] IMM_ID_EX_WIRE;
    wire [6:0]  OPCODE_ID_EX_WIRE;
    wire [9:0]  FUNCT_ID_EX_WIRE;
    wire        WB_VALID_ID_EX_WIRE;
    wire        RD_IN_PIPELINE;
    wire [4:0] RS1_SEL_WIRE;
    wire [4:0] RS2_SEL_WIRE;
    reg [31:0] WB_DATA_IN;
    
    wire [3:0]   ALU_CNT_WIRE;     
    wire [1:0]   COMP_CNT_WIRE;
    wire         MUX1_CNT_WIRE;
    wire         MUX2_CNT_WIRE;
    wire         MUX3_CNT_WIRE; 
   //MEM3 Stage registers
    reg [6:0]   OPCODE_MEM3_WB;
    reg [31:0] ALU_OUT_MEM3_WB; //MEM3 out to MEM1 in
    reg COMP_OUT_MEM3_WB;
    reg [4:0] RD_MEM3_WB;
    reg WB_VALID_MEM3_WB;
    reg STALL_ENABLE;
    reg STALL_ENABLE_1;
    reg FLAG1;
    reg STALL_ENABLE_FINAL_CYCLE;
    
   
    IDSTAGE ID(
        //.PC_IN(PC_IF_ID),
        .INS_IN(INS_IF_ID),
        .CLK(CLK),
        .RD_OUT(RD_ID_EX_WIRE),
        .IMM_OUT(IMM_ID_EX_WIRE),
        .RS1_SEL(RS1_SEL_WIRE),
        .RS2_SEL(RS2_SEL_WIRE),
        .RS1_DATAOUT(RS1_ID_EX_WIRE),
        .RS2_DATAOUT(RS2_ID_EX_WIRE),
        //.PC_OUT,
        .OPCODE_OUT(OPCODE_ID_EX_WIRE),
        .FUNCT_OUT(FUNCT_ID_EX_WIRE),
        .RD_IN_PIPELINE(RD_IN_PIPELINE),
        .WB_VALID_OUT(WB_VALID_ID_EX_WIRE),
        .WB_DATA_IN(WB_DATA_IN),
        .WB_VALID_INPUT(WB_VALID_MEM3_WB),
        .RD_WB(RD_MEM3_WB),
        .ALU_CNT(ALU_CNT_WIRE),     
        .COMP_CNT(COMP_CNT_WIRE),
        .MUX1_CNT(MUX1_CNT_WIRE),
        .MUX2_CNT(MUX2_CNT_WIRE),
        .MUX3_CNT(MUX3_CNT_WIRE) 
    );
    
    reg [31:0] PC_ID_EX; //ID out to EX in
    reg [4:0] RD_ID_EX;
    reg [4:0] RS1_SEL_ID_EX;
    reg [4:0] RS2_SEL_ID_EX;
    reg [31:0] RS1_ID_EX;
    reg [31:0] RS2_ID_EX;
    reg [31:0] IMM_ID_EX;
    reg [6:0] OPCODE_ID_EX;
    reg [9:0] FUNCT_ID_EX;
    reg WB_VALID_ID_EX;
    
    reg [3:0] ALU_CNT_ID_EX;     
    reg [1:0]   COMP_CNT_ID_EX;
    reg   MUX1_CNT_ID_EX;
    reg   MUX2_CNT_ID_EX;
    reg   MUX3_CNT_ID_EX; 
    
    //Execute stage
    wire [31:0] ALU_OUT_WIRE;
    wire COMP_OUT_WIRE;
    reg         BRANCH_TAKEN_L;
    reg         BRANCH_TAKEN_REG;
    wire [31:0] FEEDBACK_RS1_FINAL;
    wire [31:0] FEEDBACK_RS2_FINAL;
    wire [31:0] RS1;
    wire [31:0] RS2;
    reg [31:0] RS1_L;
    reg [31:0] RS2_L;

    wire ENABLE_FEEDBACK_RS1_CNT;
    wire ENABLE_FEEDBACK_RS2_CNT;
    
    assign RS1 = (~STALL_ENABLE)? RS1_ID_EX : FEEDBACK_RS1_FINAL;
    assign RS2 = (~STALL_ENABLE)? RS2_ID_EX : FEEDBACK_RS2_FINAL;
    
    
    EXSTAGE EX(
        .PC_IN(PC_ID_EX),
        .RS1_IN(RS1_ID_EX),
        .RS2_IN(RS2_ID_EX),
        .IMM_IN(IMM_ID_EX),//IMM_ID_EX_WIRE),
        .OPCODE_IN(OPCODE_ID_EX),//OPCODE_ID_EX_WIRE),
        .FUNCT_IN(FUNCT_ID_EX),//FUNCT_ID_EX_WIRE),
        .ALU_CNT_IN(ALU_CNT_ID_EX),     
        .COMP_CNT_IN(COMP_CNT_ID_EX),
        .MUX1_CNT_IN(MUX1_CNT_ID_EX),
        .MUX2_CNT_IN(MUX2_CNT_ID_EX),
        .MUX3_CNT_IN(MUX3_CNT_ID_EX),
        .ALU_OUT(ALU_OUT_WIRE),
        .COMP_OUT(COMP_OUT_WIRE)
     );
         
         
         reg [6:0] OPCODE_EX_MEM1;
         reg [31:0] RS2_EX_MEM1;
         reg [31:0] ALU_OUT_EX_MEM1; //EX out to MEM1 in
         reg COMP_OUT_EX_MEM1;
         reg [4:0] RD_EX_MEM1;
         reg WB_VALID_EX_MEM1;
         
         assign ALU =  ALU_OUT_EX_MEM1;
         assign COMPAR = COMP_OUT_EX_MEM1;
         assign BRANCH_TAKEN = BRANCH_TAKEN_L;
         assign BRANCH_ADDRESS = ALU_OUT_EX_MEM1;
         assign PIPELINE_STALL = STALL_ENABLE && STALL_ENABLE_1;
       /*
         reg [4:0] RD_EX_MEM;
         reg [6:0] OPCODE_EX_MEM;
         reg [14:0] FUNCT_EX_MEM;
         //reg BRANCH_TAKEN_EX_MEM;
     */
     
     
    //MEM1 Stage registers
    reg [6:0] OPCODE_MEM1_MEM2;
    reg [31:0] ALU_OUT_MEM1_MEM2; //MEM1 out to MEM1 in
    reg COMP_OUT_MEM1_MEM2;
    reg [4:0] RD_MEM1_MEM2;
    reg WB_VALID_MEM1_MEM2;
    //MEM2 Stage registers
    reg [6:0] OPCODE_MEM2_MEM3;
    reg [31:0] ALU_OUT_MEM2_MEM3; //MEM2 out to MEM3 in
    reg COMP_OUT_MEM2_MEM3;
    reg [4:0] RD_MEM2_MEM3;
    reg WB_VALID_MEM2_MEM3;
   
    
    
    
    //feedback controller
    
    wire [31:0] FEEDBACK_VALUE_RS1;
    wire [31:0] FEEDBACK_VALUE_RS2;
    
    
    reg [31:0] RS1_DEL1;
    reg [31:0] RS2_DEL1;
    
    
    FEEDBACK_CONTROLE FBC(
        .RS1_SEL(RS1_SEL_WIRE),//RS1_SEL_ID_EX),
        .RS2_SEL(RS2_SEL_WIRE),//RS2_SEL_ID_EX),
        .EN(CACHE_READY),
        .STALL_ENABLE(STALL_ENABLE),        //used to flush the shift reg if a branch is taken
     //   .RD_IN_PIPELINE(),
        .RD_VALID(WB_VALID_ID_EX_WIRE && STALL_ENABLE && STALL_ENABLE_1 && !(BRANCH_TAKEN_REG || BRANCH_TAKEN_L)),
        .RD_OUT(RD_ID_EX_WIRE),
        .CLK(CLK),
        .ALU_OUT_EX_MEM1_WIRE(ALU_OUT_WIRE),
     //   .RD_EX_MEM1_WIRE(RD_ID_EX),
        .ALU_OUT_EX_MEM1(ALU_OUT_EX_MEM1),
        //input COMP_OUT_EX_MEM1,
     //   .RD_EX_MEM1(RD_EX_MEM1),
        .ALU_OUT_MEM1_MEM2(ALU_OUT_MEM1_MEM2),
     //   .RD_MEM1_MEM2(RD_MEM1_MEM2),
        .ALU_OUT_MEM2_MEM3(ALU_OUT_MEM2_MEM3),
     //   .RD_MEM2_MEM3(RD_MEM2_MEM3),
        .ALU_OUT_MEM3_WB( WB_DATA_IN),
     //   .RD_MEM3_WB(RD_MEM3_WB),
        .UPDATED_RS1_VALUE(FEEDBACK_VALUE_RS1),
        .UPDATED_RS2_VALUE(FEEDBACK_VALUE_RS2),
        .MUX_RS1_SEL(ENABLE_FEEDBACK_RS1_CNT),
        .MUX_RS2_SEL(ENABLE_FEEDBACK_RS2_CNT)
        );
        
    MUX_2to1_32bit FB_MUX_1(
        .IN1(RS1_ID_EX_WIRE),
        .IN2(FEEDBACK_VALUE_RS1),
        .OP(FEEDBACK_RS1_FINAL),
        .CONTROL(ENABLE_FEEDBACK_RS1_CNT)
        );
        
    MUX_2to1_32bit FB_MUX_2(
        .IN1(RS2_ID_EX_WIRE),
        .IN2(FEEDBACK_VALUE_RS2),
        .OP(FEEDBACK_RS2_FINAL),
        .CONTROL(ENABLE_FEEDBACK_RS2_CNT));
    
    
    //TEMP meory to emulate data cache
    
    wire [31:0] ALU_OUT_MEM2_MEM3_WIRE;
    reg  [3:0] WEA;
    reg   ENA;
    blk_mem_gen_0 DATA_CACHE(
    .addra(ALU_OUT_EX_MEM1),
    .clka(CLK),
    .dina(RS2_EX_MEM1),
    .douta(ALU_OUT_MEM2_MEM3_WIRE),
    .ena(ENA),
    .wea(WEA)
    );    
    
    initial
    begin
        STALL_ENABLE = 1'b1; //stalls when off
        STALL_ENABLE_1 =1'b1;
        STALL_ENABLE_FINAL_CYCLE = 1'b0;
        BRANCH_TAKEN_L = 1'b0;
        BRANCH_TAKEN_REG = 1'b0;
    end
       
    
    always@(*)
    begin
    
    //STALL_ENABLE signal generation
    //This signal stalls the full pipeline upto EX stage and keeps the remaining DM stages and WB stages running
    //Feedback is done to the ID_EX buffer

           if(OPCODE_EX_MEM1 == 7'b0000011) 
               STALL_ENABLE = #7 1'b0;
           else if(OPCODE_MEM1_MEM2 == 7'b0000011) 
               STALL_ENABLE = #7 1'b0;
           else if(OPCODE_MEM2_MEM3 == 7'b0000011) 
               STALL_ENABLE = #7 1'b0;
           else if(OPCODE_MEM3_WB == 7'b0000011) 
               STALL_ENABLE = #7 1'b0;
           else
               STALL_ENABLE = #7 1'b1;
           
    //branch output controle
           if(OPCODE_EX_MEM1 == 7'b1100011)
               BRANCH_TAKEN_L = COMP_OUT_EX_MEM1;    
           else if(OPCODE_EX_MEM1 == 7'b1101111 || OPCODE_EX_MEM1 == 7'b1100111)
               BRANCH_TAKEN_L = 1'b1;    
           else
               BRANCH_TAKEN_L = 1'b0;
               
    //branch detection at EX stage
           if(OPCODE_ID_EX == 7'b1100011 || OPCODE_ID_EX == 7'b1101111 || OPCODE_ID_EX == 7'b1100111)
               STALL_ENABLE_1 = 1'b0;    
           else
               STALL_ENABLE_1 = 1'b1;
               
               
           if(OPCODE_ID_EX == 7'b0000011 && FLAG1)
           begin
               STALL_ENABLE_1 = 1'b0;   
               FLAG1 = 1'b0; 
           end
           else
           begin
               STALL_ENABLE_1 = 1'b1;
               FLAG1 = 1'b1;
           end
    //Emulation signal generation which are used running the block ram  
    
           if(OPCODE_EX_MEM1 == 7'b0100011)
           begin
               WEA = 4'd1;
               ENA = 4'd1;
           end
           //read from cache
           else if(OPCODE_EX_MEM1 == 7'b0000011) 
           begin
               WEA = 4'd0;
               ENA = 4'd1;
           end
           else if(OPCODE_MEM1_MEM2 == 7'b0000011) 
           begin
               WEA = 4'd0;
               ENA = 4'd1; 
           end
           else if(OPCODE_MEM2_MEM3 == 7'b0000011) 
           begin
               WEA = 4'd0;
               ENA = 4'd1; 
           end
           else
           begin
               WEA = 4'd0;
               ENA = 4'd0; 
           end            
    end
    
    
    //Used to select values correctly from data cache emulator or buffer
    always@(OPCODE_MEM3_WB or ALU_OUT_MEM2_MEM3_WIRE or ALU_OUT_MEM3_WB)
    begin
           if(OPCODE_MEM3_WB ==  7'b0000011)
                WB_DATA_IN = ALU_OUT_MEM2_MEM3_WIRE;
           else
                WB_DATA_IN = ALU_OUT_MEM3_WB;
    end
    
    

    //counter1 is used to find the fnal clock cycle when stall enable is given
    integer COUNTER1 = 32'd0;
    //COUNTER2 is used to flush the IF ID EX stages of the pipeline at a true branch instruction
    integer COUNTER2 = 32'd0;

    always@(posedge CLK)
    begin
        if(CACHE_READY)
        begin
        //registering branch taken control signal
        if(BRANCH_TAKEN_L)
            BRANCH_TAKEN_REG <= 1'b1;
        
        if(COUNTER2 == 32'd2)
        begin
            BRANCH_TAKEN_REG <= 1'b0;
        end
             
        if(BRANCH_TAKEN_REG && CACHE_READY)
            COUNTER2 <= COUNTER2 + 1;
        else if(CACHE_READY)
            COUNTER2 <= 32'd0;
            
        
        
            
        if(STALL_ENABLE)
        begin
        
            if(BRANCH_TAKEN_REG || BRANCH_TAKEN_L)
            begin
             //updating ID/EX buffer0
          
             //data signals
            
             PC_ID_EX    <=  32'd0; 
             RD_ID_EX <= 5'd0;
             RS1_DEL1 <= 5'd0;
             RS2_DEL1 <= 5'd0;
             RS1_ID_EX<= 32'd0;
             RS2_ID_EX<= 32'd0;
             IMM_ID_EX<= 32'd0;
             OPCODE_ID_EX<= 7'd0;
             FUNCT_ID_EX<= 10'd0;
             WB_VALID_ID_EX <=1'b0;
             RS1_SEL_ID_EX <= 5'd0 ;
             RS2_SEL_ID_EX <= 5'd0 ;
           
             //Control signals
             ALU_CNT_ID_EX <= 4'd0;     
             COMP_CNT_ID_EX <= 2'd0;
             MUX1_CNT_ID_EX <= 1'b0;
             MUX2_CNT_ID_EX <= 1'b0;
             MUX3_CNT_ID_EX <= 1'b0;
           
             
             COUNTER1 <= 32'd0;
           
           //Updating EX/MEM1 buffer
           
           
             OPCODE_EX_MEM1<= 7'd0;
             RS2_EX_MEM1      <=  5'd0;
             ALU_OUT_EX_MEM1  <=  32'd0; 
             COMP_OUT_EX_MEM1 <=  1'b0;
             RD_EX_MEM1 <= 5'd0;
             WB_VALID_EX_MEM1 <= 1'b0;
             
            end
            else
            begin
            //updating ID/EX buffer0
           
            //data signals
            
            PC_ID_EX    <=  PC_IF_ID; 
            RD_ID_EX <= RD_ID_EX_WIRE;
            RS1_DEL1 <= RS1_ID_EX_WIRE;
            RS2_DEL1 <= RS2_ID_EX_WIRE;
            RS1_ID_EX<= FEEDBACK_RS1_FINAL;
            RS2_ID_EX<= FEEDBACK_RS2_FINAL;
            IMM_ID_EX<= IMM_ID_EX_WIRE;
            OPCODE_ID_EX<= OPCODE_ID_EX_WIRE;
            FUNCT_ID_EX<= FUNCT_ID_EX_WIRE;
            WB_VALID_ID_EX <=WB_VALID_ID_EX_WIRE && STALL_ENABLE_1;
            RS1_SEL_ID_EX <= RS1_SEL_WIRE ;
            RS2_SEL_ID_EX <= RS2_SEL_WIRE ;
            
            //Control signals
            ALU_CNT_ID_EX <= ALU_CNT_WIRE;     
            COMP_CNT_ID_EX <= COMP_CNT_WIRE;
            MUX1_CNT_ID_EX <= MUX1_CNT_WIRE;
            MUX2_CNT_ID_EX <= MUX2_CNT_WIRE;
            MUX3_CNT_ID_EX <= MUX3_CNT_WIRE;
            
            
            COUNTER1 <= 32'd0;
            
            //Updating EX/MEM1 buffer
            
            
            OPCODE_EX_MEM1<= OPCODE_ID_EX;
            RS2_EX_MEM1      <=  RS2_ID_EX;
            ALU_OUT_EX_MEM1  <=  ALU_OUT_WIRE; 
            COMP_OUT_EX_MEM1 <=  COMP_OUT_WIRE;
            RD_EX_MEM1 <= RD_ID_EX;
            WB_VALID_EX_MEM1 <= WB_VALID_ID_EX;
            end
           
        end
        else
        begin
        
           
            COUNTER1 <= COUNTER1 + 1;
            
            if(COUNTER1 == 32'd3)
            begin
                 if(RS1_SEL_ID_EX == RD_MEM3_WB && WB_VALID_MEM3_WB == 1'b1 )
                           RS1_ID_EX<= FEEDBACK_RS1_FINAL;
                 if(RS2_SEL_ID_EX == RD_MEM3_WB && WB_VALID_MEM3_WB == 1'b1 )
                           RS2_ID_EX<= FEEDBACK_RS2_FINAL;
            end
            
           //makes sure garbage values are not fed into the pipeline at a stall
            WB_VALID_EX_MEM1 <= 1'b0; 
            OPCODE_EX_MEM1   <=  7'd0; 
  
//                if(ENABLE_FEEDBACK_RS1_CNT == 1'b1)
//                begin
//                    RS1_ID_EX<= FEEDBACK_RS1_FINAL;
//                end
//                if(ENABLE_FEEDBACK_RS2_CNT == 1'b1)
//                begin
//                    RS2_ID_EX<= FEEDBACK_RS2_FINAL;
//                end        
        end


       
        //updating MEM1/MEM2 buffer
        ALU_OUT_MEM1_MEM2 <= ALU_OUT_EX_MEM1;//ALU_OUT_EX_MEM1; 
        OPCODE_MEM1_MEM2 <= OPCODE_EX_MEM1;
        COMP_OUT_MEM1_MEM2 <= COMP_OUT_EX_MEM1; //COMP_OUT_EX_MEM1;
        RD_MEM1_MEM2 <= RD_EX_MEM1;
        WB_VALID_MEM1_MEM2 <= WB_VALID_EX_MEM1;
        
        //updating MEM2/MEM3 buffer
       
        OPCODE_MEM2_MEM3 <= OPCODE_MEM1_MEM2;
//        if(OPCODE_MEM1_MEM2 ==  7'b0000011 || OPCODE_MEM2_MEM3  ==  7'b0000011)
//            ALU_OUT_MEM2_MEM3 <= ALU_OUT_MEM2_MEM3_WIRE; 
//        else
        ALU_OUT_MEM2_MEM3 <= ALU_OUT_MEM1_MEM2; 
        COMP_OUT_MEM2_MEM3 <= COMP_OUT_MEM1_MEM2;
        RD_MEM2_MEM3 <= RD_MEM1_MEM2;
        WB_VALID_MEM2_MEM3 <= WB_VALID_MEM1_MEM2;
        
        //update MEM3/WB buffer
        OPCODE_MEM3_WB <= OPCODE_MEM2_MEM3;
        ALU_OUT_MEM3_WB <= ALU_OUT_MEM2_MEM3; 
        COMP_OUT_MEM3_WB <= COMP_OUT_MEM2_MEM3;
        RD_MEM3_WB <= RD_MEM2_MEM3;
        WB_VALID_MEM3_WB <= WB_VALID_MEM2_MEM3;            
      end
    end
endmodule
