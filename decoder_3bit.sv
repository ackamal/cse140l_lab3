module decoder_4bit (
  input logic[3:0] bits,
	output logic[1:0] ew_str_light, ew_left_light, ns_light);

	always_comb case (bits)
		'b0000:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
		'b0001:
			{ew_str_light, ew_left_light, ns_light} = 6'b10_00_00;
		'b0010:
			{ew_str_light, ew_left_light, ns_light} = 6'b01_00_00;
		'b0011:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_10_00;
		'b0100:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_01_00;
		'b0101:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_10;
		'b0110:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_01;
		'b0111:
			{ew_left_light, ew_str_light, ns_light} = 6'b00_00_00;
		'b1110:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
		'b1101:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
		'b1111:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
		default: 
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
	endcase

endmodule
