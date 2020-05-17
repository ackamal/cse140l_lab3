// test bench for grading Lab 3
// CSE140L   Fall 2019
module grading_testbench;

logic clk = 1'b0;	                  
logic reset = 1'b1;			  // should put your design in all-red
logic ew_left_sensor,		  // left traffic on e-w street
	  ew_str_sensor,		  // thru traffic on e-w street
	  ns_sensor;              // traffic on n-s street
wire [1:0] ew_left_light,     // left arrow e-w turn onto n-s
	       ew_str_light,	  // straight ahead e-w
	       ns_light;	      // n-s (no left/thru differentiation)
typedef enum logic[1:0] {red,yellow,green} color;
int points = 0;
// your controller goes here
// input ports = logics above
// output ports = wires above (each 2 bits wide)
traffic_light_controller dut(.*);

color ew_l, ew_s, ns;
assign ew_l = color'(dut.ew_left_light);
assign ew_s = color'(dut.ew_str_light);
assign ns   = color'(dut.ns_light);

always begin
  #5ns clk = 1'b1;	 
  #5ns clk = 1'b0;
// print yellow and green states on transcript
  case({ew_left_light,ew_str_light,ns_light})
    6'b00_00_00: $display("           %t",$time);
	6'b01_00_00: $display("y          %t",$time);
	6'b10_00_00: $display("g          %t",$time);
	6'b00_01_00: $display("   y       %t",$time);
	6'b00_10_00: $display("   g       %t",$time);
	6'b00_00_01: $display("       y   %t",$time);
	6'b00_00_10: $display("       g   %t",$time);
	default    : $display("***ERROR** %t",$time);
  endcase 
end

logic [3:0] test_cnt = 4'b0;          // lets testbench track tests
initial begin
  $display("e   e   n");	   // header for y, g status display
  $display("w   w   s");
  $display("l   s    ");
  ew_left_sensor = 1'b0;
  ew_str_sensor  = 1'b0;
  ns_sensor      = 1'b0;
  #20ns reset    = 1'b0;
  #10ns;
  
// traffic only at EWS
  test_cnt++;
  ew_str_sensor = 1'b1;
  wait(ew_s == green); 
  #30ns ew_str_sensor = 1'b0;
  #200ns;
 
// Test EW_LEFT to EW_STR without more traffic
  test_cnt++;
  ew_left_sensor= 1'b1;
  fork
    begin
      #10ns ew_str_sensor = 1'b1;
      wait   (ew_s == green);
	  #30ns ew_str_sensor = 1'b0;
	end
    begin
      wait 	(ew_l == green);
      #30ns ew_left_sensor = 1'b0 ;
	end
  join
  #200ns;
  
// Now set traffic at NS. Green NS lasts past sensor falling
  test_cnt++                  ;
  ns_sensor           = 1'b1  ;
  wait (ns == green); 
  #30ns ns_sensor     = 1'b0  ;
  #200ns;


// Test NS to EW_STR without more traffic
  test_cnt++                  ;
  ns_sensor       = 1'b1 ;
  fork
    begin
      #10ns ew_str_sensor = 1'b1;
      wait   (ew_s == green);
	  #30ns ew_str_sensor = 1'b0;
	end
    begin
      wait 	(ns == green);
      #30ns ns_sensor = 1'b0 ;
	end
  join
  #200ns; 
 
// Test EW_STR to NS without more traffic
  test_cnt++                  ;
  ew_str_sensor       = 1'b1 ;
  fork
    begin
      #10ns ns_sensor = 1'b1;
      wait   (ns == green);
	  #30ns ns_sensor = 1'b0;
	end
    begin
      wait 	(ew_s == green);
      #30ns ew_str_sensor = 1'b0 ;
	end
  join
  #200ns;   
  
  
// Check NS again, but hold for more than 5 cycles.  
//   NS should cycle green-yellow-red when side traffic appears
  test_cnt++;
  ns_sensor              = 1'b1;
  #100ns  ew_left_sensor = 1'b1;
  fork
    begin
      wait (ns == green);    
      #20ns ns_sensor    = 1'b0;
    end
	begin
	  wait (ew_l	== green)
	  #10ns ew_left_sensor = 1'b0;
	end
  join
  #100ns;

//Test reset to all red state  
  reset = 1'b1;
  #20ns reset = 1'b0;
  #50ns;
  
// All three sensors become 1 at once.  
//  EW_STR should come first, then EW_LEFT, then NS
  test_cnt++;
  ew_left_sensor = 1'b1;
  ew_str_sensor  = 1'b1;
  ns_sensor      = 1'b1;
  #1000ns;
  ew_left_sensor = 1'b0;
  #200ns;
  ew_str_sensor  = 1'b0;
  ns_sensor      = 1'b0;
  #200ns;

  
// ew_left_sensor turns on first, other two turn on after
// Should give each lane a chance 
  test_cnt++;
  ew_left_sensor = 1'b1;
  #30ns;
  ew_str_sensor  = 1'b1;
  ns_sensor      = 1'b1;
  #1000ns;
  ew_left_sensor = 1'b0;
  #200ns;
  ew_str_sensor  = 1'b0;
  ns_sensor      = 1'b0;
  #200ns;
  $stop;
end

endmodule
