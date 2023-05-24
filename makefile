GHDL=ghdl
WAVE=gtkwave
FLAGS="--std=08"
count:
	@$(GHDL) -a $(FLAGS) count_ones_tb.vhd count_ones.vhd 
	@$(GHDL) -e $(FLAGS) count_ones_tb
	@$(GHDL) -r $(FLAGS) count_ones_tb --wave=wave.ghw --stop-time=1us
	@$(WAVE) --dump=wave.ghw

encode:
	@$(GHDL) -a $(FLAGS) TMDS_8b10b_encoder_tb.vhd count_ones.vhd TMDS_8b10b_encoder.vhd
	@$(GHDL) -e $(FLAGS) TMDS_8b10b_encoder_tb
	@$(GHDL) -r $(FLAGS) TMDS_8b10b_encoder_tb --wave=wave.ghw --stop-time=1us
	@$(WAVE) --dump=wave.ghw

decode:
	@$(GHDL) -a $(FLAGS) TMDS_decoder_tb.vhd count_ones.vhd TMDS_8b10b_encoder.vhd TMDS_decoder.vhd
	@$(GHDL) -e $(FLAGS) TMDS_decoder_tb
	@$(GHDL) -r $(FLAGS) TMDS_decoder_tb --wave=wave.ghw --stop-time=1us
	@$(WAVE) --dump=wave.ghw