module tb_Checkpoint4;

logic clk;
 
MemoryController dut_inst(clk);

always  #5 clk=!clk;

initial begin
clk=0;

#5000000;
$finish;
end
endmodule