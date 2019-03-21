`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Juozas Pazera s1554371
// 
// Create Date: 22.01.2019 10:14:36
// Design Name: 
// Module Name: IRTransmitterSM
// Project Name: IR_interface
// Target Devices: Digilent Basys 3 Board
// Tool Versions: 
// Description: This module takes car parameters as an input and outputs the right pulse sequence.
//              Pulses in sequence are at car operating frequency and are transmitted 10 times/s.
// 
// Dependencies: Generic_counter module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IRTransmitterSM(
    input CLK,
    input [3:0] Command,
    input [7:0] StartBurstSize,
    input [5:0] CarSelectBurstSize,
    input [5:0] GapSize,
    input [5:0] AssertBurstSize,
    input [4:0] DeAssertBurstSize,
    input FrequencyTrigger,
    input FrequencyPulse,
    output IRLed
    );
    
    // Generic counter moudule to output a trigger 10 times/s
    Generic_counter # (.COUNTER_WIDTH(24),
                       .COUNTER_MAX(10000000) // 10Hz
                       )
                       Counter_10Hz(
                       .CLK(CLK),
                       .RESET(1'b0),
                       .ENABLE(1'b1),
                       .TRIG_OUT(TRIGGER_10Hz)
                           );
    
    reg [2:0] CURR_STATE;
    reg [2:0] NEXT_STATE;
    reg [8:0] COUNT = 0;
    reg PACKET_OUT;
    reg ENABLE = 0;
    
    // State machine that waits for the trigger from 10Hz to generic counter module and starts transmitting the pulse sequence            
    always @ (posedge FrequencyTrigger, posedge TRIGGER_10Hz) begin
        if(TRIGGER_10Hz)
            ENABLE <= 1;
        else if (ENABLE) begin
            case (CURR_STATE)
                3'd0: begin // Generates Start pulses + gap
                    if (COUNT < StartBurstSize*2) begin
                        PACKET_OUT <= FrequencyPulse;
                        COUNT <= COUNT + 1;
                    end
                    else if (COUNT >= StartBurstSize*2 & COUNT < (StartBurstSize*2 + GapSize*2)) begin
                        PACKET_OUT <= 0;
                        COUNT <= COUNT + 1;
                    end
                    else begin
                        COUNT <= 0;
                        PACKET_OUT <= 0;
                        NEXT_STATE <= 3'd1;
                    end
                end
                
                3'd1: begin // Generates Car select pulses + gap
                    if (COUNT < CarSelectBurstSize*2) begin
                        PACKET_OUT <= FrequencyPulse;
                        COUNT <= COUNT + 1;
                    end
                    else if (COUNT >= CarSelectBurstSize*2 & COUNT < (CarSelectBurstSize*2 + GapSize*2)) begin
                        PACKET_OUT <= 0;
                        COUNT <= COUNT + 1;
                    end
                    else begin
                        COUNT <= 0;
                        PACKET_OUT <= 0;
                        NEXT_STATE <= 3'd2;
                    end
                end
                
                3'd2: begin // Generates Right pulses + gap
                    if (Command[3]) begin // If right command is given
                        if (COUNT < AssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= AssertBurstSize*2 & COUNT < (AssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            NEXT_STATE <= 3'd3;
                        end
                    end
                    else begin // If right command is not given
                        if (COUNT < DeAssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= DeAssertBurstSize*2 & COUNT < (DeAssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            PACKET_OUT <= 0;
                            NEXT_STATE <= 3'd3;
                        end
                    end
                end
                
                3'd3: begin // Generates left pulses + gap
                    if (Command[2]) begin // If left command is given
                        if (COUNT < AssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= AssertBurstSize*2 & COUNT < (AssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            NEXT_STATE <= 3'd4;
                        end
                    end
                    else begin // If left command is not given
                        if (COUNT < DeAssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= DeAssertBurstSize*2 & COUNT < (DeAssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            PACKET_OUT <= 0;
                            NEXT_STATE <= 3'd4;
                        end
                    end
                end
                
                3'd4: begin // Generates backward pulses + gap
                    if (Command[1]) begin // If Backwards command is given
                        if (COUNT < AssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= AssertBurstSize*2 & COUNT < (AssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            PACKET_OUT <= 0;
                            NEXT_STATE <= 3'd5;
                        end
                    end
                    else begin // If Backwards command is not given
                        if (COUNT < DeAssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= DeAssertBurstSize*2 & COUNT < (DeAssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            PACKET_OUT <= 0;
                            NEXT_STATE <= 3'd5;
                        end
                    end
                end
                
                3'd5: begin // Generates forward pulses + gap
                    if (Command[0]) begin // If Forward command is given
                        if (COUNT < AssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= AssertBurstSize*2 & COUNT < (AssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            PACKET_OUT <= 0;
                            NEXT_STATE <= 3'd0;
                        end
                    end
                    else begin // If forward command is not given
                        if (COUNT < DeAssertBurstSize*2) begin
                            PACKET_OUT <= FrequencyPulse;
                            COUNT <= COUNT + 1;
                        end
                        else if (COUNT >= DeAssertBurstSize*2 & COUNT < (DeAssertBurstSize*2 + GapSize*2)) begin
                            PACKET_OUT <= 0;
                            COUNT <= COUNT + 1;
                        end
                        else begin
                            COUNT <= 0;
                            PACKET_OUT <= 0;
                            ENABLE <= 0;
                            NEXT_STATE <= 3'd0;
                        end
                    end
                end
                
                default: begin
                    PACKET_OUT <= 0;
                    NEXT_STATE <= 3'd0;
                end
            endcase
        end
            
        CURR_STATE <= NEXT_STATE;
        
    end
   
    assign IRLed = PACKET_OUT;

    
endmodule
