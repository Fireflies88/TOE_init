module TOE_tb;
			logic clk;
			logic reset;
			logic write;
			logic read;
			logic chipselect;
			logic address;
			logic [63:0] writedata;
			logic [31:0] readdata;
			
reg [2:0]i=0; //internal, just to initialize REQ_NEW once and only once
logic [1:0] NEW_REQUEST; // input
logic [1:0] KILL_REQUEST; // input
logic [3:0] KILL_ID; // input
reg [3:0] NEW_ID; // output
reg[1:0] DONE; // output
reg[1:0] ERROR; //output

logic addr; //input --pass to RAM?
reg EXISTING_reg; //WRITE_ENABLEd for the RAM (which is actually internal to the check)
reg [35:0] local_registers; //this stores the values of input connection data temporarily 



TOE_init dut(.*); //should take all required values

//sets a clock
initial begin
clk=0;
forever
#20ns clk= ~clk;
end

always(posedge clk)begin
//initially starts a request for DUT
if (i==2)begin

writedata[1:0]<=1; //writerequest
NEW_REQUEST<=writedata[1:0];
writedata[3:2]<=0; //killrequest
writedata[7:4]<=0; //killid


NEW_ID<=readdata[3:0];
DONE<=readdata[5:4];
ERROR<=readdata[7:6];

i<=i+2'b1;
end
else begin
i=i+2'b1;
writedata[1:0]<=0; //writerequest
NEW_REQUEST<=writedata[1:0];
writedata[3:2]<=0; //killrequest
writedata[7:4]<=0; //killid


NEW_ID<=readdata[3:0];
DONE<=readdata[5:4];
ERROR<=readdata[7:6];
end
end

always@(posedge clk)begin

if(NEW_REQUEST)begin

//then, given the request is succesfully, it should pass in these values for the local_registers
//only when DONE is on does it do this
writedata[13:8]<=11111; //srcmac
writedata[18:14]<=00000; //dstmac
writedata[25:19]<=10101010; //srcip
writedata[31:26]<=0001110; //dstip
writedata[36:32]<=1000011;//srcport
writedata[41:37]<=0111100;//dstport
end
end

endmodule
