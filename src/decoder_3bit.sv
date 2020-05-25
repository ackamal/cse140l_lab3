module decoder_3bit (
  input logic[2:0] bits,
	output logic[1:0] ew_str_light, ew_left_light, ns_light);

	always_comb case (bits)
		'b000:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_00;
		'b001:
			{ew_str_light, ew_left_light, ns_light} = 6'b10_00_00;
		'b010:
			{ew_str_light, ew_left_light, ns_light} = 6'b01_00_00;
		'b011:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_10_00;
		'b100:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_01_00;
		'b101:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_10;
		'b110:
			{ew_str_light, ew_left_light, ns_light} = 6'b00_00_01;
		'b111:
			{ew_left_light, ew_str_light, ns_light} = 6'b00_00_00;
	endcase

endmodule
