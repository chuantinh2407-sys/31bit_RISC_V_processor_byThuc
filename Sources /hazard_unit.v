// Hazards Unit - HU

module hazard_unit (

    // Load-use hazard detection
    input  wire        MemtoRegE,  
    input  wire [4:0]  RS1D,       
    input  wire [4:0]  RS2D,        
    input  wire [4:0]  RDE,  
       
    // Forwarding
    input  wire [4:0]  RS1E,        
    input  wire [4:0]  RS2E,        
    input  wire [4:0]  RDM,         
    input  wire [4:0]  RDW,         
    input  wire        RegWriteM,
    input  wire        RegWriteW,

    // Control hazard (branch/jump taken)
    input  wire [1:0]  PCSrcE,
    input  wire        RESET,

    // Outputs
    output reg         StallF,
    output reg         StallD,
    output reg         FlushD,
    output reg         FlushE,
    output reg  [1:0]  ForwardAE,
    output reg  [1:0]  ForwardBE
);

    // Forwarding logic
    always @(*) begin
        // ForwardAE
        if (RegWriteM && (RDM != 5'd0) && (RDM == RS1E))
            ForwardAE = 2'b10;           // forward from EX/MA
        else if (RegWriteW && (RDW != 5'd0) && (RDW == RS1E))
            ForwardAE = 2'b01;           // forward from MA/WB
        else
            ForwardAE = 2'b00;        

        // ForwardBE
        if (RegWriteM && (RDM != 5'd0) && (RDM == RS2E))
            ForwardBE = 2'b10;
        else if (RegWriteW && (RDW != 5'd0) && (RDW == RS2E))
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end

    // Load-use hazard
    wire lw_stall = MemtoRegE &&
                    ((RDE == RS1D) || (RDE == RS2D));

    always @(*) begin
        if (RESET) begin
            StallF = 1'b0;
            StallD = 1'b0;
            FlushE = 1'b0;
        end else if (lw_stall) begin
            StallF = 1'b1;  // stall PC
            StallD = 1'b1;  // stall IF/ID
            FlushE = 1'b1;  // Flush ID/EX
        end else begin
            StallF = 1'b0;
            StallD = 1'b0;
            FlushE = 1'b0;
        end
    end

    //Control hazard
    always @(*) begin
        if (RESET)
            FlushD = 1'b0;
        else if (PCSrcE == 2'b01 || PCSrcE == 2'b10)
            FlushD = 1'b1;  // flush IF/ID 
        else
            FlushD = 1'b0;
    end

endmodule
