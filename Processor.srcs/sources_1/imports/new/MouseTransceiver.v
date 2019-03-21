`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Main Author: Unknown
//Co-author: Lea Georgieva
//Contribution by the Co-author to the code:
//lines 159, 160 and 181:186
// 
//Last Modified on: 11.02.2019 10:51:38
// Module Name: MouseTransceiver
// Project Name: Mouse_PS2_interface
// Target Devices: Basys3 board (with Microblaze processor on the Artix-7 FPGA)
// Tool Versions: Vivado 2017.2

// Description: 
//This module combines the three sub-modules that drive the 
//the PS2 communication.
//It also collects the raw data received by them and processes it 
//to make it in in a more convinient form to use 
//(for example by the VGA interface that was used to display the mouse
//on a screen)
//////////////////////////////////////////////////////////////////////////////////



module MouseTransceiver(
    //Standard Inputs
    input RESET,                  //tied to button T17 of the board
    input CLK,                    //the built in 100MHz clock
    //PS2 interface
    inout CLK_MOUSE,             //The clock line of the PS2 interface
    inout DATA_MOUSE,            //The data line of the PS2 interface
     // Mouse data information
    output reg [3:0] MouseStatus = 0,
    output reg [7:0] MouseX = 0,
    output reg [7:0] MouseY = 0
 );
// X, Y Limits of Mouse Position e.g. VGA Screen with 160 x 120 resolution
parameter [7:0] MouseLimitX = 160;
parameter [7:0] MouseLimitY = 120;
/////////////////////////////////////////////////////////////////////
//TriState Signals
//Clk
reg ClkMouseIn = 0;
wire ClkMouseOutEnTrans;
//Data
wire DataMouseIn;
wire DataMouseOutTrans;
wire DataMouseOutEnTrans;
//Clk Output - can be driven by host or device
assign CLK_MOUSE = ClkMouseOutEnTrans ? 1'b0 : 1'bz;
//Clk Input
assign DataMouseIn = DATA_MOUSE;
//Data Output - can be driven by host or device
assign DATA_MOUSE = DataMouseOutEnTrans ? DataMouseOutTrans : 1'bz;
/////////////////////////////////////////////////////////////////////
//This section filters the incoming Mouse clock to make sure that
//it is stable before data is latched by either transmitter
//or receiver modules
reg [7:0]MouseClkFilter = 0;
always@(posedge CLK) begin
    if(RESET)
        ClkMouseIn <= 1'b0;
    else begin
    //A simple shift register
        MouseClkFilter[7:1] <= MouseClkFilter[6:0];
        MouseClkFilter[0] <= CLK_MOUSE;
    //falling edge
        if(ClkMouseIn & (MouseClkFilter == 8'h00))
            ClkMouseIn <= 1'b0;
        //rising edge
        else if(~ClkMouseIn & (MouseClkFilter == 8'hFF))
            ClkMouseIn <= 1'b1;
    end
end
///////////////////////////////////////////////////////
//Instantiate the Transmitter module
wire SendByteToMouse;
wire ByteSentToMouse;
wire [7:0] ByteToSendToMouse;
wire [3:0] Transmitter_State;
MouseTransmitter T(
//Standard Inputs
.RESET (RESET),
.CLK(CLK),
//Mouse IO - CLK
.CLK_MOUSE_IN(ClkMouseIn),
.CLK_MOUSE_OUT_EN(ClkMouseOutEnTrans),
//Mouse IO - DATA
.DATA_MOUSE_IN(DataMouseIn),
.DATA_MOUSE_OUT(DataMouseOutTrans),
.DATA_MOUSE_OUT_EN(DataMouseOutEnTrans),
//Control
.SEND_BYTE(SendByteToMouse),
.BYTE_TO_SEND(ByteToSendToMouse),
.BYTE_SENT(ByteSentToMouse)
);
///////////////////////////////////////////////////////
//Instantiate the Receiver module
wire ReadEnable;
wire [7:0] ByteRead;
wire [1:0] ByteErrorCode;
wire ByteReady;
wire [2:0] Receiver_State;
MouseReceiver R(
//Standard Inputs
    .RESET(RESET),
    .CLK(CLK),
    //Mouse IO - CLK
    .CLK_MOUSE_IN(ClkMouseIn),
    //Mouse IO - DATA
    .DATA_MOUSE_IN(DataMouseIn),
    //Control
    .READ_ENABLE (ReadEnable),
    .BYTE_READ(ByteRead),
    .BYTE_ERROR_CODE(ByteErrorCode),
    .BYTE_READY(ByteReady)
);
///////////////////////////////////////////////////////
//Instantiate the Master State Machine module
wire [7:0] MouseStatusRaw;
wire [7:0] MouseDxRaw;
wire [7:0] MouseDyRaw;
wire SendInterrupt;
wire [3:0] MSM_Curr_State;

MouseMasterSM MSM(
//Standard Inputs
    .RESET(RESET),
    .CLK(CLK),
    //Transmitter Interface
    .SEND_BYTE(SendByteToMouse),
    .BYTE_TO_SEND(ByteToSendToMouse),
    .BYTE_SENT(ByteSentToMouse),
    //Receiver Interface
    .READ_ENABLE (ReadEnable),
    .BYTE_READ(ByteRead),
    .BYTE_ERROR_CODE(ByteErrorCode),
    .BYTE_READY(ByteReady),
    //Data Registers
    .MOUSE_STATUS(MouseStatusRaw),
    .MOUSE_DX(MouseDxRaw),
    .MOUSE_DY(MouseDyRaw),
    .SEND_INTERRUPT(SendInterrupt)
);

//Pre-processing - handling of overflow and signs.
//More importantly, this keeps tabs on the actual X/Y
//location of the mouse.
wire signed [8:0] MouseDx;
wire signed [8:0] MouseDy;
wire signed [8:0] MouseNewX;
wire signed [8:0] MouseNewY;
//DX and DY are modified to take account of overflow and direction
//DX modification
assign MouseDx = (MouseStatusRaw[6]) ? (MouseStatusRaw[4] ? {MouseStatusRaw[4],8'h00} :
{MouseStatusRaw[4],8'hFF} ) : {MouseStatusRaw[4],MouseDxRaw[7:0]};
 //DY modification
 assign MouseDy = (MouseStatusRaw[7]) ? (MouseStatusRaw[5] ? {MouseStatusRaw[5],8'h00} :
 {MouseStatusRaw[5],8'hFF} ) : {MouseStatusRaw[5],MouseDyRaw[7:0]};

 // calculate new mouse position
assign MouseNewX = {1'b0,MouseX} + MouseDx;
assign MouseNewY = {1'b0,MouseY} + MouseDy;
always@(posedge CLK) begin
    if(RESET) begin   //if RESET, place in the centre
        MouseStatus <= 0;
        MouseX <= MouseLimitX/2;
        MouseY <= MouseLimitY/2;
    end else if (SendInterrupt) begin
    //Status is stripped of all unnecessary info
        MouseStatus <= MouseStatusRaw[3:0];
        //X is modified based on DX with limits on max and min
        if(MouseNewX < 0)
            MouseX <= 0;
        else if(MouseNewX > (MouseLimitX-1))
            MouseX <= MouseLimitX-1;
        else
            MouseX <= MouseNewX[7:0];
        //Y is modified based on DY with limits on max and min
        if(MouseNewY < 0)
            MouseY <= 0;
         else if(MouseNewY > (MouseLimitY-1))
            MouseY <= MouseLimitY-1;
         else
            MouseY <= MouseNewY[7:0];
    
     
    end
end
endmodule


