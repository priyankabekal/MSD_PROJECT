module Checkpoint12(
  input clk
);

int mode, input_file, m, previouscycle;
int line, count, count_clocks;
int output_file;
string scan_input, scan_output;
int cycletime, cycletimeR;
bit [1:0] operation;
bit [31:0] address;
bit [1:0] operationR;
bit [31:0] addressR;
string queue [$:16];
int counter [$:16];
bit [0:7] counter_idx;
string temp, file_name;

parameter PRE = 0;
parameter WRITE = 1;
parameter READ = 2;
parameter ACT = 3;

initial begin
  count = 0;
  //counter_idx = 0;
  //$value$plusargs ("mode=%d", mode);
  //if($value$plusargs("tracefile=%s",file_name))begin
    input_file = $fopen("file_name.txt", "r");
    if(input_file == 0) begin
	  //if(mode == 1)
	  $display("File was NOT opened successfully : %0d", input_file);
	  $stop;
	end 
end

always@(posedge clk) begin

  count++;
  count_clocks++;

  if($feof(input_file)) begin
    $fclose(input_file);
	$stop;
  end
  else begin
    if(queue.size() == 0)
	  begin
	    $fgets(scan_input, input_file);
		m = $sscanf(scan_input, "%d %d %h",cycletime, operation, address);
		
		if(cycletime <= previouscycle) begin
		  //if (mode == 1)
		  $display("error in time in line %d",line);
		  $stop;
		end
		else if (m != 3) begin
		  //if (mode == 1)
		  $display ("ERROR: Current line [%s] not formatted correctly", scan_input);
		  $stop;
		end
		else if (operation>2) begin
		  //if (mode == 1)
		  $display("invalid operation in line [%s]",scan_input);
		  $stop;
		end
		
		count = cycletime;
		
		queue.push_back(scan_input);
		$sscanf(queue, "%d %d %h", cycletime, operation, address);
		$display("Insert 1 - Current Simulation Time: %0d, Request Time: %0d, Operation: %0d, Address: %h, Bankgroup: %d, Bank: %d, row: %d, column: %d",
		  count, cycletime, operation, address, address[7:6], address[9:8], {address[17:10],address[5:3]}, address[31:18]);
		
		counter.push_back(cycletime + 100);
		//$display("Queue size: %0d, counter size: %0d, count_clocks = %0d, count = %0d",queue.size, counter.size, count_clocks, count);
    //previouscycle = cycletime;
	$display("previous cycle: %0d, cycletime: %0d", previouscycle,cycletime);
	  end
	else if(queue.size() < 16 && queue.size() != 0)
	  begin
	  
		if(counter[0] == count_clocks) begin
		  temp = queue.pop_front();
		  $sscanf(temp, "%d %d %h", cycletimeR, operationR, addressR);
		  $display("Removed 1 - Current Simulation Time: %0d, Request Time: %0d, Operation: %0d, Address: %h",count, cycletimeR, operationR, addressR);
		  
		  counter.pop_front();
		  //$display("Removed1 from counter");
		  
		  //$display("Queue size: %0d, counter size: %0d, count_clocks = %0d, count = %0d",queue.size, counter.size, count_clocks, count);

		end
		
		  $fgets(scan_input, input_file);
		  m = $sscanf(scan_input, "%d %d %h",cycletime, operation, address);
		  
		if(cycletime <= previouscycle) begin
		  //if (mode == 1)
		  $display("error in time in line [%s]",scan_input);
		  $stop;
		end
		else if (m != 3) begin
		  //if (mode == 1)
		  $display ("ERROR: Current line [%s] not formatted correctly", scan_input);
		  $stop;
		end
		else if (operation>2) begin
		  //if (mode == 1)
		  $display("invalid operation in line [%s]",scan_input);
		  $stop;
		end
        previouscycle = cycletime;

		//if(count == cycletime) begin
		  queue.push_back(scan_input);
		  $sscanf(queue, "%d %d %h", cycletime, operation, address);
		  $display("Insert 2 - Current Simulation Time: %0d, Request Time: %0d, Operation: %0d, Address: %h, Bankgroup: %d, Bank: %d, row: %d, column: %d",
		  count, cycletime, operation, address, address[7:6], address[9:8], {address[17:10],address[5:3]}, address[31:18]);
		  
		  counter.push_back(cycletime + 100);
		//  $display("Queue size: %0d, counter size: %0d, count_clocks = %0d, count = %0d",queue.size, counter.size, count_clocks, count);
        //end
		
				
	  end
	else if(queue.size() == 16)
	  begin
	    if(counter[0] == count_clocks) begin
		  temp = queue.pop_front();
		  $sscanf(temp, "%d %d %h", cycletimeR, operationR, addressR);
		  $display("Removed 2 - Current Simulation Time: %0d, Request Time: %0d, Operation: %0d, Address: %h",count, cycletimeR, operationR, addressR);

		  //$display("Removed2 an element from queue %s", temp);
		  
		  counter.pop_front();
		  //$display("Removed2 from counter");
		  
		  //$display("Queue size: %0d, counter size: %0d, count_clocks = %0d, count = %0d",queue.size, counter.size, count_clocks, count);
          
		end
	  end	  
  end 
end
endmodule