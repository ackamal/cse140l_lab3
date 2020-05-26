// shell for advanced traffic light controller (stretch goal)
// CSE140L   Summer II  2019
// semi-independent operation of east and west straight and left signals
//  see assignment writeup

module traffic_light_controller(
	input clk,
	reset,
	ew_str_sensor,		
	ew_left_sensor,
	ns_sensor,
	output logic[1:0] ew_str_light, ew_left_light, ns_light
);			

  logic[3:0] present_state = 4'b1111; logic[3:0] next_state = 4'b1111;
  
  // Handles light changes based on current state
  decoder_4bit dcdr(.bits(present_state), .ew_str_light(ew_str_light), .ew_left_light(ew_left_light), .ns_light(ns_light));
  
  // Simple counters used to measure 2, 5, and 10-cycle durations
  logic[3:0] ct_2, ct_5, ct_10;
  logic ct_2_en, ct_5_en, ct_10_en;
  logic do_transition;
  logic current_sensor_on;
  
  // Transition to new state depending on counter values
  // TODO : change counters to not use modulus/wraparound
	always_ff @(posedge clk) begin
	
		// resets
		if (reset) begin
			ct_2 <= 0; ct_5 <= 0; ct_10 <= 0;
			ct_2_en <= 1; ct_10_en <= 1; ct_5_en <= 0;
		end
		
		// how to determine ct_	5_en
		// when the sensor of the currently green light is off, then enable
		// otherwise, maintain its last value
		// and zero it out on transitions
		if (current_sensor_on == 0) begin
			ct_5_en <= 1;
		end
		else if (current_sensor_on == 1) begin
			ct_5_en <= ct_5_en;
		end
		
		// option 1
		if (do_transition) begin
			ct_2 <= 0; ct_5 <= 0; ct_10 <= 0;
			ct_2_en <= 1; ct_10_en <= 1; ct_5_en <= 0;
		end
		else begin
		if (ct_2_en) begin
			ct_2 <= ct_2 + 4'b0001;
			end
		if (ct_5_en) begin
			ct_5 <= ct_5 + 4'b0001;
			end
		if (ct_10_en) begin
			ct_10 <= ct_10 + 4'b0001;
			end
		end
			
		// transitions
		present_state <= next_state;
		
			
	
	end /* -- always_ff -- */
	
	// Determine the next state from the current state and sensors
	always_comb begin
	
		if (reset) begin
			do_transition = 0;
			current_sensor_on = 0;
		end
	
		case (present_state)
		
			// RRR, just came from NS (priority ew_str)
			4'b1111: begin
				
				current_sensor_on = 0;
				if (ew_str_sensor) begin
					next_state = 4'b0001;
					do_transition = 1;
				end
				else if (ew_left_sensor) begin
					next_state = 4'b0011;
					do_transition = 1;
				end
				else if (ns_sensor) begin
					next_state = 4'b0101;
					do_transition = 1;
				end
				else begin
					// Remain waiting in RRR
					next_state = 4'b1111;
					do_transition = 0;
				end
			end /* -- 4'b1111 -- */
			
			// RRR, just came from EWS (priority ew_left)
			4'b1110: begin
			
				current_sensor_on = 0;
				if (ew_left_sensor) begin
					next_state = 4'b0011;
					do_transition = 1;
				end
				else if (ns_sensor) begin
					next_state = 4'b0101;
					do_transition = 1;
				end
				else if (ew_str_sensor) begin
					next_state = 4'b0001;
					do_transition = 1;
				end
				else begin
					// Remain waiting in RRR
					next_state = 4'b1110;
					do_transition = 0;
				end	
			end /* -- 4'1110 -- */
			
			// RRR, just came from EWL (priority ns)
			4'b1101: begin
				
				current_sensor_on = 0;
				if (ns_sensor) begin
					next_state = 4'b0101;
					do_transition = 1;
				end
				else if (ew_str_sensor) begin
					next_state = 4'b0001;
					do_transition = 1;
				end
				else if (ew_left_sensor) begin
					next_state = 4'b0011;
					do_transition = 1;
				end
				else begin
					// Remain waiting in RRR
					next_state = 4'b1101;
					do_transition = 0;
				end
			end /* -- 4'b1101 -- */

			// GRR
			4'b0001: begin
				if (ew_str_sensor && ct_10 < 9) begin
					// Maintain the current state
					next_state = 4'b0001;
					do_transition = 0;
					current_sensor_on = 1;
				end
				else if (ew_str_sensor && (ew_left_sensor || ns_sensor) && ct_10 >= 9) begin
					// Switch to YRR immediately if another sensor is on
					next_state = 4'b0010;
					do_transition = 1;
					current_sensor_on = 1;
				end
				else if (ct_5 >= 4) begin
					// Switch to YRR after counting 5 cycles
					next_state = 4'b0010;
					do_transition = 1;
					
					if (ew_str_sensor) 
						current_sensor_on = 1;
					else
						current_sensor_on = 0;
				end
				else if (ew_str_sensor == 0) begin
					// Begin the 5 cycle counter
					next_state = present_state;
					do_transition = 0;
					current_sensor_on = 0;
				end
				else begin
					// Maintain the current state
					next_state = 4'b0001;
					do_transition = 0;
					
					if (ew_str_sensor) 
						current_sensor_on = 1;
					else
						current_sensor_on = 0;
				end
			end /* -- 4'b0001 -- */
			
			// YRR
			4'b0010: begin
				
				// Don't care about the value of incoming traffic
				current_sensor_on = 0;
			
				if (ct_2 >= 1) begin
					// Transition to RRR
					next_state = 4'b1110;
					do_transition = 1;
				end
				else begin
					// Maintain the current state
					next_state = 4'b0010;
					do_transition = 0;
				end
			end /* -- 4'b0010 -- */

			//RGR
			4'b0011: begin
				if (ew_left_sensor && ct_10 < 9) begin
					// Maintain the current state
					next_state = 4'b0011;
					do_transition = 0;
					current_sensor_on = 1;
				end
				else if (ew_left_sensor && (ew_str_sensor || ns_sensor) && ct_10 >= 9) begin
					// Switch to RYR immediately if another sensor is on
					next_state = 4'b0100;
					do_transition = 1;
					current_sensor_on = 1;
				end
				else if (ct_5 >= 4) begin
					// Switch to RYR after counting 5 cycles
					next_state = 4'b0100;
					do_transition = 1;
					
					if (ew_left_sensor) 
						current_sensor_on = 1;
					else
						current_sensor_on = 0;
				end
				else if (ew_left_sensor == 0) begin
					// Begin the 5 cycle counter
					next_state = present_state;
					do_transition = 0;
					current_sensor_on = 0;
				end
				else begin
					// Maintain the current state
					next_state = 4'b0011;
					do_transition = 0;
					
					if (ew_left_sensor) 
						current_sensor_on = 1;
					else
						current_sensor_on = 0;
				end
			end
			// RYR
			4'b0100: begin	
				current_sensor_on = 0;
			
				if (ct_2 >= 1) begin
					// Transition to RRR
					next_state = 4'b1101;
					do_transition = 1;
				end
				else begin
					// Maintain the current state
					next_state = 4'b0100;
					do_transition = 0;
				end
			end

			// RRG
			4'b0101: begin
				if (ns_sensor && ct_10 < 9) begin
					// Maintain the current state
					next_state = 4'b0101;
					do_transition = 0;
					current_sensor_on = 1;
				end
				else if (ns_sensor && (ew_str_sensor || ew_left_sensor) && ct_10 >= 9) begin
					// Switch to RYR immediately if another sensor is on
					next_state = 4'b0110;
					do_transition = 1;
					current_sensor_on = 1;
				end
				else if (ct_5 >= 4) begin
					// Switch to RYR after counting 5 cycles
					next_state = 4'b0110;
					do_transition = 1;
					
					if (ns_sensor) 
						current_sensor_on = 1;
					else
						current_sensor_on = 0;
				end
				else if (ns_sensor == 0) begin
					// Begin the 5 cycle counter
					next_state = present_state;
					do_transition = 0;
					current_sensor_on = 0;
				end
				else begin
					// Maintain the current state
					next_state = 4'b0101;
					do_transition = 0;
					
					if (ns_sensor) 
						current_sensor_on = 1;
					else
						current_sensor_on = 0;
				end
			end
			
			// RRY
			4'b0110: begin
				current_sensor_on = 0;
			
				if (ct_2 >= 1) begin
					// Transition to RRR
					next_state = 4'b1111;
					do_transition = 1;
				end
				else begin
					// Maintain the current state
					next_state = 4'b0110;
					do_transition = 0;
				end
				
			end
			
			default: begin
				next_state = present_state;
				do_transition = 0;
				current_sensor_on = 0;
			end /* -- default -- */
			
		endcase
	end /* -- always_comb -- */
	
endmodule 


