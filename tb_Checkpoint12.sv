module tb;

logic clk;
 
Checkpoint12 dut_inst(clk);

always  #5 clk=!clk;

initial begin
clk=0;

#4000000;
$finish;
end
endmodule
