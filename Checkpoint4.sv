module Checkpoint4(
  input clk
);

bit pendingRequests;
string queue [$:16];
int input_file, numOfFields, requestTime, requestTimeOutput;
string scan_input, finishRequest;
bit [1:0] operation, operationOutput;
bit [31:0] address, addressOutput;
int currentTime;
int counter;

initial begin
  pendingRequests = 1'b0;
  counter = 0;

  input_file = $fopen("filename.txt", "r");
  if(input_file == 0) begin
	  $display("File was NOT opened successfully : %0d", input_file);
	  $stop;
  end 
end

always@(posedge clk) begin
  if(queue.size < 16) begin
    $display("1) Size of the queue: %0d", queue.size);
    if(!pendingRequests) begin
	$display("1) Have a pending request: %0d", pendingRequests);
	  if(!$feof(input_file))begin
	    $display("Is it end of the file: %0d", $feof(input_file));
	    if($fgets(scan_input, input_file)) begin
		  $display("Scan_Input returns: %0d", scan_input);
		  pendingRequests = 1'b1;
		  numOfFields = $sscanf(scan_input, "%d %d %h",requestTime, operation, address);
		  $display("2) Have a pending request: %0d", pendingRequests);
		  $display("From file - Request Time: %0d, Operation: %0d, Address: %h",requestTime, operation, address);
		  //$stop;
		end
		else if(!$feof(input_file)) begin
		  $display("Syntax error");
		  $stop;
		end
	  end
	end
  
  
  if(pendingRequests) begin
    $display("3) Have a pending request: %0d", pendingRequests);
	//$stop;
    if(queue.size == 0) begin
	  $display("2) Size of the queue: %0d", queue.size);
	  $display("1) Current Time: %0d, Request Time: %0d", currentTime, requestTime);
	  //$stop;
	  if(currentTime < requestTime) begin
	    currentTime = requestTime;
		$display("2) Current Time: %0d, Request Time: %0d", currentTime, requestTime);
		//$stop;
	  end
	end
	if(currentTime >= requestTime) begin
	  queue.push_back(scan_input);
	  pendingRequests = 1'b0;
      $display("3) Size of the queue: %0d", queue.size);
	  $display("4) Have a pending request: %0d", pendingRequests);
	  //$stop;
	end
  end
  end
  
  if(queue.size != 0) begin
  $display("4) Size of the queue: %0d", queue.size);
  //$stop;
    if(counter >= 100) begin
	    $display("1) Counter value: %0d", counter);
	  	finishRequest = queue.pop_front();
		$sscanf(finishRequest, "%d %d %h", requestTimeOutput, operationOutput, addressOutput);
		$display("From Queue - Request Time: %0d, Operation: %0d, Address: %h",requestTimeOutput, operationOutput, addressOutput);
		counter = 0;
		$display("2) Counter value: %0d", counter);
		//$stop;
	end
	else
	  counter++;
  end
  
  currentTime++;
  $display("2) Counter value: %0d", counter);
  $display("Current Time: %0d", currentTime);
  $display("***Queue size: %0d, Any pending requests: %0d, Is it end of the file: %0d, End execution: %0d***", 
    queue.size, pendingRequests, $feof(input_file), ((queue.size == 0) & (!pendingRequests) & ($feof(input_file))));
  //$display("***End execution logic working or not *(1 & (!0) & 1)*: %0d", (1 & (!0) & 0));
	
  if((queue.size == 0) & (!pendingRequests) & ($feof(input_file))) begin
    $display("Stop the operation as Queue size is %0d, Pending Requests are %0d, and end of the file is %0d",
	  queue.size, pendingRequests, $feof(input_file));
    $stop;
  end
  
  if(currentTime == 400) begin
    $stop;
  end
end

endmodule