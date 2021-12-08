module MemoryController(
  input clk
);

//parameter BANKS_BG = 4, BG = 4, DRAM_CMD = 4;

bit pendingRequests, current_request_set;
string queue [$:16];
int input_file, numOfFields, requestTime, input_clk, output_file;
string scan_input, finishRequest;
bit [1:0] operation, operationOutput;
bit [32:0] address, addressOutput;
int clk_count;
int counter;
bit [14:0] row;
bit [7:0] column;
bit [1:0] bank;
bit [1:0] bankGroup;
string commandToDisplayDRAM;
int presentDRAMCommand;
bit [1:0] previous_BG;
bit [1:0] previous_B;
int previous_CMD;

int first_request[3:0][3:0];	
int act_set[3:0][3:0]; 
int act_timer[3:0][3:0];
int WR_set[3:0][3:0];
int write_timer[3:0][3:0];
int RD_set[3:0][3:0];
int read_timer[3:0][3:0];
logic [14:0] openPage[3:0][3:0];
int Previous_bank[3:0];
int Previous_bankgroup[3:0];
int lastest_CMD[3:0][3:0];
int time_when_last_CMD_given [3:0][3:0][3:0];
int MODE;

parameter tRCD = 24, 
  tCWD = 20,
  tCAS = 24, 
  tBURST = 4,  
  tCCD = 8,
  tWTR_S = 4,
  tWTR_L = 12,
  tRAS = 52,
  tRTP =12,
  tRP = 24,
  tWR = 20,
  tCCD_L = 8,
  tCCD_S = 4,
  tRRD_L = 6,
  tRRD_S = 4;
  
parameter ACT = 0, RD = 1, WR = 2, PRE = 3;

parameter RD_D = 0, WR_D = 1, FETCH_I = 2;

initial begin
  pendingRequests = 1'b0;
  current_request_set = 0;
  counter = 0;
  /*void'($value$plusargs ("MODE=%d", MODE));
  if(MODE == 0)
    $stop;*/
  input_file = $fopen("t4.trace", "r");
  output_file = $fopen("outFileName.txt", "w");
  
  if(input_file == 0) begin
	  $display("File was NOT opened successfully : %0d", input_file);
	  $stop;
  end 
end

always@(posedge clk) begin
  if(queue.size < 16) begin
    if(!pendingRequests) begin
	  if(!$feof(input_file))begin
	    if($fgets(scan_input, input_file)) begin
		  pendingRequests = 1'b1;
		  numOfFields = $sscanf(scan_input, "%d %d %h",requestTime, operation, address);
		end
		else if(!$feof(input_file)) begin
		  $display("Syntax error");
		  $stop;
		end
	  end
	end
  
  
  if(pendingRequests) begin
    if(queue.size == 0) begin
	  if(clk_count < requestTime) begin
	    clk_count = requestTime;
		$display("1 clock count: %d", clk_count);
	  end
	end
	if(clk_count >= requestTime) begin
	  queue.push_back(scan_input);
	  pendingRequests = 1'b0;
	  $display("2 clock count: %d", clk_count);
	end
  end
  end
  
  if(queue.size != 0) begin

    if (current_request_set == 0) begin
      finishRequest = queue.pop_front();
	  current_request_set = 1 ;
	  $sscanf(finishRequest, "%d %d %h", input_clk, operation, addressOutput);
	  bankGroup = addressOutput[7:6];
      bank = addressOutput[9:8];
      column = {addressOutput[17:10]};
      row = addressOutput[32:18];
	  $display("3 clock count: %d", clk_count);
    end
	  
	if (input_clk <= clk_count) begin
	 
	  if (first_request[bankGroup][bank] != 1) begin
		  $fwrite(output_file, "%d ACT %h %h %h\n",clk_count, bankGroup, bank, row);
		  openPage[bankGroup][bank] = row; 
		  //act_timer[bankGroup][bank] = clk_count;
		  lastest_CMD[bankGroup][bank] = ACT;
		  $display("4 clock count: %d", clk_count);
		  //time_when_last_CMD_given [bankGroup][bank][ACT] = clk_count;
          clk_count = clk_count + tRCD*2;
		  
			if (operation == 1)begin
			  $fwrite(output_file, "%d WR  %h %h %h\n",clk_count, bankGroup, bank, column);
			  previous_BG = bankGroup;
			  previous_B = bank;
			  clk_count = 2*tCWD + 2*tBURST + clk_count;
			  first_request [bankGroup][bank] = 1;
			  write_timer[bankGroup][bank] = clk_count;
			  current_request_set = 0;
			  previous_CMD = WR;
			  $display("5 clock count: %d", clk_count);
			end
			else begin
			  $fwrite(output_file, "%d RD  %h %h %h\n",clk_count, bankGroup, bank, column);
			  previous_BG = bankGroup;
			  previous_B = bank;
			  clk_count = 2*tCAS + 2*tBURST + clk_count;
			  first_request [bankGroup][bank] = 1; 
			  read_timer[bankGroup][bank] = clk_count;
			  current_request_set = 0;
			  previous_CMD = RD;
			  $display("6 clock count: %d", clk_count);
			end
	  end
	  
	  else if(row == openPage[bankGroup][bank])begin
	    $display("7 clock count: %d", clk_count);
		
        if(operation == 0 || operation == 2)begin
		  $display("8 clk_count: %d, previous_CMD: %d, previous_BG: %h",clk_count,
		    previous_CMD, previous_BG);
			
		  if(previous_CMD == RD & bankGroup == previous_BG) begin
		    if(clk_count >= read_timer[bankGroup][previous_B] + 2*tCAS + 2*tBURST + 2*tCCD_L) begin
			  clk_count = clk_count;
			  $display("9 clk_count: %d, previous_CMD: %d, previous_BG: %h",clk_count,
		        previous_CMD, previous_BG);
			end
			else begin
			  if(clk_count >= read_timer[bankGroup][previous_B] + 2*tCAS + 2*tBURST) begin
			    clk_count = (2*tCCD_L - (clk_count - (read_timer[bankGroup][previous_B] + 2*tCAS + 2*tBURST))) + clk_count;
			  end
			  else begin
			    clk_count = 2*tCCD_L + clk_count;
			  end
		    end
		  end
		  else if(previous_CMD == RD & bankGroup != previous_BG) begin
		    if(clk_count >= read_timer[previous_BG][previous_B] + 2*tCAS + 2*tBURST + 2*tCCD_L) begin
			  clk_count = clk_count;
			  $display("9 clk_count: %d, previous_CMD: %d, previous_BG: %h",clk_count,
		        previous_CMD, previous_BG);
			end
			else begin
			  if(clk_count >= read_timer[previous_BG][previous_B] + 2*tCAS + 2*tBURST) begin
			    clk_count = (2*tCCD_L - (clk_count - (read_timer[previous_BG][bank] + 2*tCAS + 2*tBURST))) + clk_count;
			  end
			  else begin
			    clk_count = 2*tCCD_L + clk_count;
			  end
		    end
		  end
		  else if(previous_CMD == WR & bankGroup == previous_BG)
		    clk_count = 2*tWTR_L + clk_count;
		  else if(previous_CMD == WR & bankGroup != previous_BG)
		    clk_count = 2*tWTR_S + clk_count;


          $display("10 clock count: %d", clk_count);
		  $fwrite(output_file, "%d RD  %h %h %h\n",clk_count, bankGroup, bank, column);
		  clk_count = 2*tCAS + 2*tBURST + clk_count;
		  previous_BG = bankGroup;
		  previous_B = bank;
		  read_timer[bankGroup][bank] = clk_count;
		  current_request_set = 0;
		  previous_CMD = RD;
		end
		else if(operation ==1)begin
		  if(previous_CMD == WR & bankGroup == previous_BG) begin
		    $display("9a clock count: %d", clk_count);	  
		
		    if(clk_count >= write_timer[bankGroup][previous_B] + 2*tCWD + 2*tBURST + 2*tCCD_L) begin
			  clk_count = clk_count;
			  $display("9b clk_count: %d, previous_CMD: %d, previous_BG: %h",clk_count,
		        previous_CMD, previous_BG);
			end
			else begin
			  if(clk_count >= write_timer[bankGroup][previous_B] + 2*tCWD + 2*tBURST) begin
			    clk_count = (2*tCCD_L - (clk_count - (write_timer[bankGroup][bank] + 2*tCAS + 2*tBURST))) + clk_count;
			    $display("9c clock count: %d", clk_count);	
			  end
			  else begin
			    clk_count = 2*tCCD_L + clk_count;
			  end
		    end
		  end
		  else if(previous_CMD == WR & bankGroup != previous_BG) begin
		    if(clk_count >= write_timer[previous_BG][previous_B] + 2*tCAS + 2*tBURST + 2*tCCD_L) begin
			  clk_count = clk_count;
			  $display("9 clk_count: %d, previous_CMD: %d, previous_BG: %h",clk_count,
		        previous_CMD, previous_BG);
			end
			else begin
			  if(clk_count >= write_timer[previous_BG][previous_B] + 2*tCAS + 2*tBURST) begin
			    clk_count = (2*tCCD_L - (clk_count - (write_timer[previous_BG][bank] + 2*tCAS + 2*tBURST))) + clk_count;
			  end
			  else begin
			    clk_count = 2*tCCD_L + clk_count;
			  end
		    end
		  end

		  $fwrite(output_file, "%d WR  %h %h %h\n",clk_count, bankGroup, bank, column);
		  clk_count = 2*tCWD + 2*tBURST + clk_count;
		  previous_BG = bankGroup;
		  previous_B = bank;
		  write_timer[bankGroup][bank] = clk_count;
		  current_request_set = 0;
		  previous_CMD = WR;
		end
	  end
	
	  else begin
        $display("11 clock count: %d", clk_count);	  
		if(previous_CMD == WR) begin
		  if(clk_count >= write_timer[previous_BG][previous_B] + 2*tCWD + 2*tBURST + tWR*2)begin
		    clk_count = clk_count;
			$display("11a clock count: %d", clk_count);
		  end
		  else begin
			if(clk_count >= write_timer[previous_BG][previous_B] + 2*tCWD + 2*tBURST) begin
			  clk_count = (2*tWR - (clk_count - (write_timer[previous_BG][previous_B] + 2*tCWD + 2*tBURST))) + clk_count;
			  $display("11b clock count: %d", clk_count);
			end
			else begin
			  clk_count = tWR*2 + clk_count;
			  $display("11c clock count: %d", clk_count);
			end
		  end
		end
		
		$fwrite(output_file, "%d PRE %h %h\n",clk_count, bankGroup, bank);
		clk_count = clk_count + tRP*2;// precharge to act timing delay
		
		$fwrite(output_file, "%d ACT %h %h %h\n",clk_count, bankGroup, bank, row);
		openPage[bankGroup][bank] = row;
		clk_count = clk_count + tRCD*2;
		
		if (operation == 1)begin
			$fwrite(output_file, "%d WR  %h %h %h\n",clk_count, bankGroup, bank, column);
			clk_count = 2*tCWD + 2*tBURST + clk_count;
			previous_BG = bankGroup;
			previous_B = bank;
			write_timer[bankGroup][bank] = clk_count;
			current_request_set = 0;
			previous_CMD = WR;
		end
		else begin
			$fwrite(output_file, "%d RD  %h %h %h\n",clk_count, bankGroup, bank, column);
			clk_count = 2*tCAS + 2*tBURST + clk_count;
			previous_BG = bankGroup;
			previous_B = bank;
			read_timer[bankGroup][bank] = clk_count;
			current_request_set = 0;
			previous_CMD = RD;
		end
	
	  end
    end
  
    //clk_count++;
	$display("14 clock count: %d", clk_count);
	
    if((queue.size == 0) & (!pendingRequests) & ($feof(input_file))) begin
      $display("Stop the operation as Queue size is %0d, Pending Requests are %0d, and end of the file is %0d",
	    queue.size, pendingRequests, $feof(input_file));
      $stop;
    end
  
    if(clk_count == 500) begin
      $stop;
    end
	
  end
end
endmodule