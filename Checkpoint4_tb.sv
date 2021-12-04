module tb_Checkpoint4;

logic clk;
 
Checkpoint4 dut_inst(clk);

always  #5 clk=!clk;

initial begin
clk=0;

#4000000;
$finish;
end
endmodule

