//to be combined with module RAM_check in the places as stated
module TOE_init(
			 clk,
			 reset,
			 write,
			 read,
			 chipselect,
			 address,
			 writedata,
			  readdata);

			input wire clk;
			input wire reset;
			input wire write;
			input wire read;
			input wire chipselect;
			input wire address;
			input wire [63:0] writedata;
			output reg [31:0] readdata;
			
//registers maintaining TOE's internal state
reg [1:0] NEW_REQUEST; // input
reg [1:0] KILL_REQUEST; // input
reg [3:0] KILL_ID; // input
reg [3:0] NEW_ID; // output
reg[1:0] DONE; // output
reg[1:0] ERROR; //output
reg [5:0] src_mac; // input
reg[5:0] dst_mac; //input
reg[6:0] src_ip;  //input
reg[6:0] dst_ip;  //input
reg[4:0]src_port;  //inputs
reg[4:0]dst_port;  //input
reg addr; //input --pass to RAM?
reg EXISTING_reg; //WRITE_ENABLEd for the RAM (which is actually internal to the check)
reg [35:0] local_registers; //this stores the values of input connection data temporarily 

//the initial state of assigning register states to their values
//REQ_NEW_reg is set in tb
initial begin
DONE<=1'b1;
NEW_ID<=1'b0;
ERROR<=1'b0;
end

always@(posedge clk,posedge reset)
/********taking care of connection business********/
if(reset) begin
addr<=address;  //??
NEW_REQUEST<=1'b0;
KILL_REQUEST<=1'b0;
KILL_ID<=3'b0;
src_mac<=5'b0;
dst_mac<=5'b0;
src_ip<=6'b0;
dst_ip<=6'b0;
src_port<=4'b0;
dst_port<=4'b0;
end

else if(write && chipselect) begin
NEW_REQUEST<=writedata[1:0];
KILL_REQUEST<=writedata[3:2];
KILL_ID<=writedata[7:4];
src_mac<=writedata[13:8];
dst_mac<=writedata[18:14];
src_ip<=writedata[25:19];
dst_ip<=writedata[31:26];
src_port<=writedata[36:32];
dst_port<=writedata[41:37];
end
else if(read && chipselect)begin
readdata[3:0]<=NEW_ID;
readdata[5:4]<=DONE;
readdata[7:6]<=ERROR;
end

/********moving on to more interesting deals********/
always@(NEW_REQUEST)begin

if(DONE)begin

local_registers[5:0]<=src_mac;
local_registers[11:6]<=dst_mac;
local_registers[18:12]<=src_ip;
local_registers[25:19]<=dst_ip;
local_registers[30:26]<=src_port;
local_registers[35:31]<=dst_port;

DONE<=1'b0;
#(20) //need to put in delay here, otherwise DONE is never down
//the check of the RAM is put in here. if check outcome is that there are no 
//existing connections, then EXISTING_reg is set low. We pass it REQ_NEW_reg and the arguments of local_registers

//for now, we will set EXISTING_reg to low as if it had passed the test
//they will also pass us the ID
//EXISTING_reg=0; //note THIS IS TEMPORARY
#(20) //might have to put in the amount of delay needed for RAM check processing
if(1)begin
//values should've been set in RAM in the check module at this point
DONE<=1'b1;
NEW_REQUEST<=1'b0;
ERROR<=1'b0;
end
else if (EXISTING_reg==1)begin 
DONE<=1'b1;
ERROR<=1'b1;
NEW_REQUEST<=1'b0;
end
end
end

endmodule
