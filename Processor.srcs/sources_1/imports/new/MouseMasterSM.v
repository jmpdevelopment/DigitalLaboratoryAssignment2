`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Main Author: Unknown
//Co-author: Lea Georgieva
//Contribution by the Co-author to the code:
//lines 112 and 190:223
// 
// Last Modified on: 11.02.2019 10:51:38
// Module Name: MouseMasterSM
// Project Name: Mouse_PS2_interface
// Target Devices: Basys3 board (with Microblaze processor on the Artix-7 FPGA)
// Tool Versions: Vivado 2017.2

// Description: 
//This is the module that is responsible for sending and receiving
//data ro and from the mouse at a high protocol level (following the PS2 protocol).
//This is achieved by implementing a finite state machine.
//The protocol is summarised in the beginning of the module.
//A state for each of the protocol steps is written.
//The steps are described before each state.
//////////////////////////////////////////////////////////////////////////////////


module MouseMasterSM(
    input CLK,
    input RESET,
    //Transmitter Control
    output SEND_BYTE,
    output [7:0] BYTE_TO_SEND,
    input BYTE_SENT,
    //Receiver Control
    output READ_ENABLE,
    input [7:0] BYTE_READ,
    input [1:0] BYTE_ERROR_CODE,
    input BYTE_READY,
    //Data Registers
    output [7:0] MOUSE_DX,
    output [7:0] MOUSE_DY,
    output [7:0] MOUSE_STATUS,
    output SEND_INTERRUPT
 );
//////////////////////////////////////////////////////////////
// Main state machine - There is a setup sequence
//
// 1) Send FF -- Reset command,
// 2) Read FA -- Mouse Acknowledge,
// 2) Read AA -- Self-Test Pass
// 3) Read 00 -- Mouse ID
// 4) Send F4 -- Start transmitting command,
// 5) Read FA -- Mouse Acknowledge,
//
// If at any time this chain is broken, the SM will restart from
// the beginning. Once it has finished the set-up sequence, the read enable flag 
// is raised.
// The host is then ready to read mouse information 3 bytes at a time:
// S1) Wait for first read, When it arrives, save it to Status. Goto S2.
// S2) Wait for second read, When it arrives, save it to DX. Goto S3.
// S3) Wait for third read, When it arrives, save it to DY. Goto S1.
// Send interrupt.
//State Control
reg [3:0] Curr_State = 0, Next_State = 0;
reg [23:0] Curr_Counter, Next_Counter;
//Transmitter Control
reg Curr_SendByte = 0, Next_SendByte = 0;
reg [7:0] Curr_ByteToSend = 0, Next_ByteToSend = 0;
//Receiver Control
reg Curr_ReadEnable = 0, Next_ReadEnable = 0;
//Data Registers
reg [7:0] Curr_Status = 0, Next_Status = 0;
reg [7:0] Curr_Dx = 0, Next_Dx = 0;
reg [7:0] Curr_Dy = 0, Next_Dy = 0;
reg Curr_SendInterrupt = 0, Next_SendInterrupt = 0;
//Sequential
always@(posedge CLK) begin
    if(RESET) begin
        Curr_State <= 4'h0;
        Curr_Counter <= 0;
        Curr_SendByte <= 1'b0;
        Curr_ByteToSend <= 8'h00;
        Curr_ReadEnable <= 1'b0;
        Curr_Status <= 8'h00;
        Curr_Dx <= 8'h00;
        Curr_Dy <= 8'h00;
        Curr_SendInterrupt <= 1'b0;
    end else begin
        Curr_State <= Next_State;
        Curr_Counter <= Next_Counter;
        Curr_SendByte <= Next_SendByte;
        Curr_ByteToSend <= Next_ByteToSend;
        Curr_ReadEnable <= Next_ReadEnable;
        Curr_Status <= Next_Status;
        Curr_Dx <= Next_Dx;
        Curr_Dy <= Next_Dy;
        Curr_SendInterrupt <= Next_SendInterrupt;
    end
end
//Combinatorial
always@* begin
    Next_State = Curr_State;
    Next_Counter = Curr_Counter;
    Next_SendByte = 1'b0;
    Next_ByteToSend = Curr_ByteToSend;
    Next_ReadEnable = 1'b0;
    Next_Status = Curr_Status;
    Next_Dx = Curr_Dx;
    Next_Dy = Curr_Dy;
    Next_SendInterrupt = 1'b0;
    case(Curr_State)
    //Initialise State - Wait here for 10ms before trying to initialise the mouse.
    4'h0: begin
        if(Curr_Counter == 1000000) begin // 1/100th sec at 100MHz clock
            Next_State = 4'h1;
            Next_Counter = 0;
        end else
            Next_Counter = Curr_Counter + 1'b1;
    end
    //Start initialisation by sending FF
    4'h1: begin
        Next_State = 4'h2;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hFF;
    end
    //Wait for confirmation of the byte being sent
    4'h2: begin
        if(BYTE_SENT)
            Next_State = 4'h3;
        end
    //Wait for confirmation of a byte being received
    //If the byte is FA goto next state, else re-initialise.
    4'h3: begin
        if(BYTE_READY) begin
            if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                Next_State = 4'h4;
            else
                Next_State = 4'h0;
        end
        Next_ReadEnable = 1'b1;
     end
    //Wait for self-test pass confirmation
    //If the byte received is AA goto next state, else re-initialise
    4'h4: begin
        if(BYTE_READY) begin
            if((BYTE_READ == 8'hAA) & (BYTE_ERROR_CODE == 2'b00))
                Next_State = 4'h5;
            else
                Next_State = 4'h0;
        end
        Next_ReadEnable = 1'b1;
    end
    //Wait for confirmation of a byte being received
    //If the byte is 00 goto next state (MOUSE ID) else re-initialise
    4'h5: begin
        if(BYTE_READY) begin
            if((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00))
                Next_State = 4'h6;
             else
                Next_State = 4'h0;
         end
         Next_ReadEnable = 1'b1;
     end
    //Send F4 - to start mouse transmit
    4'h6: begin
        Next_State = 4'h7;
        Next_SendByte = 1'b1;
        Next_ByteToSend = 8'hF4;
   end
    //Wait for confirmation of the byte being sent
    4'h7: if(BYTE_SENT) Next_State = 4'h8; 
    //Wait for confirmation of a byte being received
    //If the byte is F4 goto next state, else re-initialise
    4'h8: begin
        if(BYTE_READY) begin
            if(BYTE_READ == 8'hF4)
                Next_State = 4'h9;
            else
                Next_State = 4'h0;
        end
        Next_ReadEnable = 1'b1;
    end
    ///////////////////////////////////////////////////////////
    //At this point the SM has initialised the mouse.
    //Now we are constantly reading. If at any time
    //there is an error, we will re-initialise
    //the mouse - just in case.
    ///////////////////////////////////////////////////////////
    //Wait for the confirmation of a byte being received.
    //This byte will be the first of three, the status byte.
    //If a byte arrives, but is corrupted, then we re-initialise
    4'h9: begin
     if(BYTE_READY) begin
         if(BYTE_ERROR_CODE == 2'b00) begin
           Next_Status = BYTE_READ;
           Next_State = 4'hA;
         end else
            Next_State = 4'h0;
     end
     Next_ReadEnable = 1'b1;
     end
    //Wait for confirmation of a byte being received
    //This byte will be the second of three, the Dx byte.
    4'hA: begin
     if(BYTE_READY) begin
          if(BYTE_ERROR_CODE == 2'b00) begin
            Next_Dx = BYTE_READ;
            Next_State = 4'hB;
          end else
             Next_State = 4'h0;
      end
      Next_ReadEnable = 1'b1;
    end
    //Wait for confirmation of a byte being received
    //This byte will be the third of three, the Dy byte.
    4'hB: begin
    if(BYTE_READY) begin
          if(BYTE_ERROR_CODE == 2'b00) begin
            Next_Dy = BYTE_READ;
            Next_State = 4'hC;
          end else
             Next_State = 4'h0;
      end
      Next_ReadEnable = 1'b1;
    end
    //Send Interrupt State
    4'hC: begin
        Next_State = 4'h9;
        Next_SendInterrupt = 1'b1;
     end
    //Default State
     default: begin
         Next_State = 4'h0;
         Next_Counter = 0;
         Next_SendByte = 1'b0;
         Next_ByteToSend = 8'hFF;
         Next_ReadEnable = 1'b0;
         Next_Status = 8'h00;
         Next_Dx = 8'h00;
         Next_Dy = 8'h00;
         Next_SendInterrupt = 1'b0;
     end
    endcase
end
///////////////////////////////////////////////////
//Tie the SM signals to the IO
//Transmitter
assign SEND_BYTE = Curr_SendByte;
assign BYTE_TO_SEND = Curr_ByteToSend;
//Receiver
assign READ_ENABLE = Curr_ReadEnable;
//Output Mouse Data
assign MOUSE_DX = Curr_Dx;
assign MOUSE_DY = Curr_Dy;
assign MOUSE_STATUS = Curr_Status;
assign SEND_INTERRUPT = Curr_SendInterrupt;

endmodule
