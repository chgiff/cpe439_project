module xillydemo
  (
  input  clk_100,
  input  otg_oc,   
  inout [55:0] PS_GPIO,
  output [3:0] GPIO_LED,
  output [4:0] vga4_blue,
  output [5:0] vga4_green,
  output [4:0] vga4_red,
  output  vga_hsync,
  output  vga_vsync,
  output  audio_mclk,
  output  audio_dac,
  input  audio_adc,
  input  audio_bclk,
  input  audio_adc_lrclk,
  input  audio_dac_lrclk,
  output  audio_mute,
  output  hdmi_clk_p,
  output  hdmi_clk_n,
  output [2:0] hdmi_d_p,
  output [2:0] hdmi_d_n,
  output  hdmi_out_en,
  inout  smb_sclk,
  inout  smb_sdata   
  ); 

   // Clock and quiesce
   wire    bus_clk;
   wire    quiesce;
   
   wire [1:0] smbus_addr;

   // Memory arrays
   reg [7:0] demoarray[0:31];
   
   reg [7:0] litearray0[0:31];
   reg [7:0] litearray1[0:31];
   reg [7:0] litearray2[0:31];
   reg [7:0] litearray3[0:31];

   // Wires related to /dev/xillybus_mem_8
   wire      user_r_mem_8_rden;
   wire      user_r_mem_8_empty;
   reg [7:0] user_r_mem_8_data;
   wire      user_r_mem_8_eof;
   wire      user_r_mem_8_open;
   wire      user_w_mem_8_wren;
   wire      user_w_mem_8_full;
   wire [7:0] user_w_mem_8_data;
   wire       user_w_mem_8_open;
   wire [4:0] user_mem_8_addr;
   wire       user_mem_8_addr_update;

   // Wires related to /dev/xillybus_read_32
   wire       user_r_read_32_rden;
   wire       user_r_read_32_empty;
   wire [31:0] user_r_read_32_data;
   wire        user_r_read_32_eof;
   wire        user_r_read_32_open;

   // Wires related to /dev/xillybus_read_8
   wire        user_r_read_8_rden;
   wire        user_r_read_8_empty;
   wire [7:0]  user_r_read_8_data;
   wire        user_r_read_8_eof;
   wire        user_r_read_8_open;

   // Wires related to /dev/xillybus_write_32
   wire        user_w_write_32_wren;
   wire        user_w_write_32_full;
   wire [31:0] user_w_write_32_data;
   wire        user_w_write_32_open;

   // Wires related to /dev/xillybus_write_8
   wire        user_w_write_8_wren;
   wire        user_w_write_8_full;
   wire [7:0]  user_w_write_8_data;
   wire        user_w_write_8_open;

   // Wires related to /dev/xillybus_audio
   wire        user_r_audio_rden;
   wire        user_r_audio_empty;
   wire [31:0] user_r_audio_data;
   //wire [31:0] user_r_audio_processed_data;
   
   wire        user_r_audio_eof;
   wire        user_r_audio_open;
   wire        user_w_audio_wren;
   wire        user_w_audio_full;
   wire [31:0] user_w_audio_data;
   wire        user_w_audio_open;
 
   // Wires related to /dev/xillybus_smb
   wire        user_r_smb_rden;
   wire        user_r_smb_empty;
   wire [7:0]  user_r_smb_data;
   wire        user_r_smb_eof;
   wire        user_r_smb_open;
   wire        user_w_smb_wren;
   wire        user_w_smb_full;
   wire [7:0]  user_w_smb_data;
   wire        user_w_smb_open;

   // Wires related to Xillybus Lite
   wire        user_clk;
   wire        user_wren;
   wire [3:0]  user_wstrb;
   wire        user_rden;
   reg [31:0]  user_rd_data;
   wire [31:0] user_wr_data;
   wire [31:0] user_addr;
   reg        user_irq;
   
   //wires for dft
   reg signed [17:0] dft_data_in;
   reg [5:0] dft_size;
   wire signed [17:0] dft_re_data_out;
   wire signed [17:0] dft_im_data_out;
   wire [35:0] dft_re_data_out_squared;
   wire [35:0] dft_im_data_out_squared;
   wire [3:0] dft_blk_exp;
   reg dft_first_data_in;
   wire dft_first_data_out;
   wire dft_data_valid;
   wire dft_input_ready;

   // Note that none of the ARM processor's direct connections to pads is
   // attached in the instantion below. Normally, they should be connected as
   // toplevel ports here, but that confuses Vivado 2013.4 to think that
   // some of these ports are real I/Os, causing an implementation failure.
   // This detachment results in a lot of warnings during synthesis and
   // implementation, but has no practical significance, as these pads are
   // completely unrelated to the FPGA bitstream.

   xillybus xillybus_ins (

    // Ports related to /dev/xillybus_mem_8
    // FPGA to CPU signals:
    .user_r_mem_8_rden(user_r_mem_8_rden),
    .user_r_mem_8_empty(user_r_mem_8_empty),
    .user_r_mem_8_data(user_r_mem_8_data),
    .user_r_mem_8_eof(user_r_mem_8_eof),
    .user_r_mem_8_open(user_r_mem_8_open),

    // CPU to FPGA signals:
    .user_w_mem_8_wren(user_w_mem_8_wren),
    .user_w_mem_8_full(user_w_mem_8_full),
    .user_w_mem_8_data(user_w_mem_8_data),
    .user_w_mem_8_open(user_w_mem_8_open),

    // Address signals:
    .user_mem_8_addr(user_mem_8_addr),
    .user_mem_8_addr_update(user_mem_8_addr_update),


    // Ports related to /dev/xillybus_read_32
    // FPGA to CPU signals:
    .user_r_read_32_rden(user_r_read_32_rden),
    .user_r_read_32_empty(user_r_read_32_empty),
    .user_r_read_32_data(user_r_read_32_data),
    .user_r_read_32_eof(user_r_read_32_eof),
    .user_r_read_32_open(user_r_read_32_open),


    // Ports related to /dev/xillybus_read_8
    // FPGA to CPU signals:
    .user_r_read_8_rden(user_r_read_8_rden),
    .user_r_read_8_empty(user_r_read_8_empty),
    .user_r_read_8_data(user_r_read_8_data),
    .user_r_read_8_eof(user_r_read_8_eof),
    .user_r_read_8_open(user_r_read_8_open),


    // Ports related to /dev/xillybus_write_32
    // CPU to FPGA signals:
    .user_w_write_32_wren(user_w_write_32_wren),
    .user_w_write_32_full(user_w_write_32_full),
    .user_w_write_32_data(user_w_write_32_data),
    .user_w_write_32_open(user_w_write_32_open),


    // Ports related to /dev/xillybus_write_8
    // CPU to FPGA signals:
    .user_w_write_8_wren(user_w_write_8_wren),
    .user_w_write_8_full(user_w_write_8_full),
    .user_w_write_8_data(user_w_write_8_data),
    .user_w_write_8_open(user_w_write_8_open),

    // Ports related to /dev/xillybus_audio
    // FPGA to CPU signals:
    .user_r_audio_rden(user_r_audio_rden),
    .user_r_audio_empty(user_r_audio_empty),
    .user_r_audio_data(user_r_audio_data),
    .user_r_audio_eof(user_r_audio_eof),
    .user_r_audio_open(user_r_audio_open),

    // CPU to FPGA signals:
    .user_w_audio_wren(user_w_audio_wren),
    .user_w_audio_full(user_w_audio_full),
    .user_w_audio_data(user_w_audio_data),
    .user_w_audio_open(user_w_audio_open),

    // Ports related to /dev/xillybus_smb
    // FPGA to CPU signals:
    .user_r_smb_rden(user_r_smb_rden),
    .user_r_smb_empty(user_r_smb_empty),
    .user_r_smb_data(user_r_smb_data),
    .user_r_smb_eof(user_r_smb_eof),
    .user_r_smb_open(user_r_smb_open),

    // CPU to FPGA signals:
    .user_w_smb_wren(user_w_smb_wren),
    .user_w_smb_full(user_w_smb_full),
    .user_w_smb_data(user_w_smb_data),
    .user_w_smb_open(user_w_smb_open),

    // Xillybus Lite signals:
    .user_clk ( user_clk ),
    .user_wren ( user_wren ),
    .user_wstrb ( user_wstrb ),
    .user_rden ( user_rden ),
    .user_rd_data ( user_rd_data ),
    .user_wr_data ( user_wr_data ),
    .user_addr ( user_addr ),
    .user_irq ( user_irq ),
			  			  
    // General signals
    .clk_100(clk_100),
    .otg_oc(otg_oc),
    .PS_GPIO(PS_GPIO),
    .GPIO_LED(GPIO_LED),
    .bus_clk(bus_clk),
    .quiesce(quiesce),

    // HDMI (DVI) related signals
    .hdmi_clk_p(hdmi_clk_p),
    .hdmi_clk_n(hdmi_clk_n),
    .hdmi_d_p(hdmi_d_p),
    .hdmi_d_n(hdmi_d_n),
    .hdmi_out_en(hdmi_out_en),			  

    // VGA port related outputs			    
    .vga4_blue(vga4_blue),
    .vga4_green(vga4_green),
    .vga4_red(vga4_red),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync)
  );

   //assign      user_irq = 0; // No interrupts for now
   /*
   always @(posedge user_clk)
     begin
	if (user_wstrb[0])
	  litearray0[user_addr[6:2]] <= user_wr_data[7:0];

	if (user_wstrb[1])
	  litearray1[user_addr[6:2]] <= user_wr_data[15:8];

	if (user_wstrb[2])
	  litearray2[user_addr[6:2]] <= user_wr_data[23:16];

	if (user_wstrb[3])
	  litearray3[user_addr[6:2]] <= user_wr_data[31:24];
	
	if (user_rden)
	  user_rd_data <= { litearray3[user_addr[6:2]],
			    litearray2[user_addr[6:2]],
			    litearray1[user_addr[6:2]],
			    litearray0[user_addr[6:2]] };
     end
   */
   
   // A simple inferred RAM
   always @(posedge bus_clk)
     begin
	if (user_w_mem_8_wren)
	  demoarray[user_mem_8_addr] <= user_w_mem_8_data;
	
	if (user_r_mem_8_rden)
	  user_r_mem_8_data <= demoarray[user_mem_8_addr];	  
     end

   assign  user_r_mem_8_empty = 0;
   assign  user_r_mem_8_eof = 0;
   assign  user_w_mem_8_full = 0;
   
   
   // 32-bit loopback
   fifo_32x512 fifo_32
     (
      .clk(bus_clk),
      .srst(!user_w_write_32_open && !user_r_read_32_open),
      .din(user_w_write_32_data),
      .wr_en(user_w_write_32_wren),
      .rd_en(user_r_read_32_rden),
      .dout(user_r_read_32_data),
      .full(user_w_write_32_full),
      .empty(user_r_read_32_empty)
      );

   assign  user_r_read_32_eof = 0;
   
   
   
   // 8-bit loopback
   fifo_8x2048 fifo_8
     (
      .clk(bus_clk),
      .srst(!user_w_write_8_open && !user_r_read_8_open),
      .din(user_w_write_8_data),
      .wr_en(user_w_write_8_wren),
      .rd_en(user_r_read_8_rden),
      .dout(user_r_read_8_data),
      .full(user_w_write_8_full),
      .empty(user_r_read_8_empty)
      );

   assign  user_r_read_8_eof = 0;
   
   
   i2s_audio audio
     (
      .bus_clk(bus_clk),
      .clk_100(clk_100),
      .quiesce(quiesce),

      .audio_mclk(audio_mclk),
      .audio_dac(audio_dac),
      .audio_adc(audio_adc),
      .audio_adc_lrclk(audio_adc_lrclk),
      .audio_dac_lrclk(audio_dac_lrclk),
      .audio_mute(audio_mute),
      .audio_bclk(audio_bclk),
      
      .user_r_audio_rden(user_r_audio_rden),
      .user_r_audio_empty(user_r_audio_empty),
      .user_r_audio_data(user_r_audio_data),
      .user_r_audio_eof(user_r_audio_eof),
      .user_r_audio_open(user_r_audio_open),
      
      .user_w_audio_wren(user_w_audio_wren),
      .user_w_audio_full(user_w_audio_full),
      .user_w_audio_data(user_w_audio_data),
      .user_w_audio_open(user_w_audio_open)
      );
   
   smbus smbus
     (
      .bus_clk(bus_clk),
      .quiesce(quiesce),

      .smb_sclk(smb_sclk),
      .smb_sdata(smb_sdata),
      .smbus_addr(smbus_addr),

      .user_r_smb_rden(user_r_smb_rden),
      .user_r_smb_empty(user_r_smb_empty),
      .user_r_smb_data(user_r_smb_data),
      .user_r_smb_eof(user_r_smb_eof),
      .user_r_smb_open(user_r_smb_open),
      
      .user_w_smb_wren(user_w_smb_wren),
      .user_w_smb_full(user_w_smb_full),
      .user_w_smb_data(user_w_smb_data),
      .user_w_smb_open(user_w_smb_open)
      );
     
      
      parameter SUB_SAMPLING = 4; //reduction factor for audio sampling rate
      parameter SAMPLES_PER_DATA = 768; //number of audio samples in each dft
      parameter DFT_CONFIG = 26; //config input for dft that corresponds to SAMPLES_PER_DATA
      parameter FREQ_BIN_SIZE = 48000 / SUB_SAMPLING / SAMPLES_PER_DATA; //width of each frequency bin in Hz
      
      dft_0 dft_0
           (.BLK_EXP(dft_blk_exp),
            .CLK(bus_clk),
            .DATA_VALID(dft_data_valid),
            .FD_IN(dft_first_data_in),
            .FD_OUT(dft_first_data_out),
            .FWD_INV(1),
            .RFFD(dft_input_ready),
            .SIZE(DFT_CONFIG),
            .XK_IM(dft_im_data_out),
            .XK_RE(dft_re_data_out),
            .XN_IM(0),
            .XN_RE(dft_data_in)
      );
      
      mult_gen_0 mult_re
            (.CLK(bus_clk),
             .A(dft_re_data_out),
             .B(dft_re_data_out),
             .P(dft_re_data_out_squared)
      );
        
      mult_gen_0 mult_im
            (.CLK(bus_clk),
             .A(dft_im_data_out),
             .B(dft_im_data_out),
             .P(dft_im_data_out_squared)
      );
      
      wire [63:0] clk_mult_out;
      mult_gen_1 mult_const(
            .A(user_wr_data),
            .P(clk_mult_out)
      );

      
      /* Audio */
      //reading in
      reg [15:0] samples_collected = 0;
      reg [4:0] subsamples_collected = 0;
      reg [15:0] input_samples [SAMPLES_PER_DATA-1:0];
      reg [15:0] input_overflow [7:0];
      reg [15:0] cur_input_sample;
      
      /* User memory */
      reg [31:0] target_freq; //frequency to match
      reg [31:0] freq_delta; //how much frequency can be off by and still match
      reg [63:0] clk_count_to_recog = 'hFFFFFFFFFFFFFFFF; //how many clock cycles the frequency must match to trigger recognition
      
      /* Timer */
      reg [63:0] timer_count;
      reg timer_enable;
      reg [63:0] timer_target;
      
      /* DFT */
      //stage 1 multiply (done in multiplier module with a pipeline level of 3)
      reg stage_1_p1_dft_data_valid; //pipeline  1
      reg [3:0] stage_1_p1_dft_blk_exp;
      reg stage_1_p1_dft_first_data_out;
      reg stage_1_p2_dft_data_valid; //pipeline  2
      reg [3:0] stage_1_p2_dft_blk_exp;
      reg stage_1_p2_dft_first_data_out;
      reg stage_1_p3_dft_data_valid; //pipeline  3
      reg [3:0] stage_1_p3_dft_blk_exp;
      reg stage_1_p3_dft_first_data_out;
      
      //stage 2 add and bit shift
      reg [65:0] output_power_total;
      reg stage_2_dft_data_valid;
      reg stage_2_dft_first_data_out;
      
      //stage 3 evaluate max power frequency
      reg [15:0] cur_output_sample;
      reg [63:0] dft_max_output;
      reg [15:0] dft_max_freq;
      reg [15:0] dft_prev_max_freq;
      reg inputing_data;
      reg outputing_data;
      reg ready_for_dft;
      
      //write from linux to fpga
      always @(posedge user_clk) begin
          if(user_wren) begin
              case(user_addr[6:2])
                0: target_freq <= user_wr_data;
                1: freq_delta <= user_wr_data;
                2: clk_count_to_recog <= clk_mult_out; //input will be in ms, must convert to clk cycles (at 100MHz)
              endcase
          end          
      end
      
      //timer
      always @(posedge bus_clk) begin: timer
         timer_count <= timer_count + 1;
         if(timer_enable && timer_target == timer_count) begin
            user_irq <= 1;
         end
         else if(user_irq) begin
            user_irq <= 0;
            timer_count <= timer_count - clk_count_to_recog;
         end
         //else begin
         //   user_irq <= 0;
         //end
      end
      
      //collect samples from audio input
      always @(posedge bus_clk) begin: audio_in
         reg [15:0] temp_sample;
         if(user_r_audio_rden) begin
            if(subsamples_collected == SUB_SAMPLING-1) begin
               subsamples_collected <= 0;
               temp_sample <= 0;
               
               if(samples_collected == SAMPLES_PER_DATA-1) begin
                   samples_collected <= 0;
                   ready_for_dft <= 1;
               end
               else begin
                   samples_collected <= samples_collected + 1;
                   ready_for_dft <= 0;          
               end
               if(samples_collected <= 7) begin
                   input_overflow[samples_collected] <= ((temp_sample + user_r_audio_data[15:0]) / SUB_SAMPLING);
               end
               else if(samples_collected == 8) begin
                   input_samples[0] = input_overflow[0];
                   input_samples[1] = input_overflow[1];
                   input_samples[2] = input_overflow[2];
                   input_samples[3] = input_overflow[3];
                   input_samples[4] = input_overflow[4];
                   input_samples[5] = input_overflow[5];
                   input_samples[6] = input_overflow[6];
                   input_samples[7] = input_overflow[7];
                   input_samples[8] = ((temp_sample + user_r_audio_data[15:0]) / SUB_SAMPLING);
               end
               else begin
                   input_samples[samples_collected] <= ((temp_sample + user_r_audio_data[15:0]) / SUB_SAMPLING);
               end
            end
            else begin
               subsamples_collected <= subsamples_collected + 1;
               temp_sample <= temp_sample + user_r_audio_data[15:0];
            end
         end
     end
     
     task double_shift_value; 
        inout [65:0] value;
        input [3:0] shift;
        begin
              case(shift)
                 0: value = (value <<< 0); 
                 1: value = (value <<< 2); 
                 2: value = (value <<< 4); 
                 3: value = (value <<< 6); 
                 4: value = (value <<< 8); 
                 5: value = (value <<< 10);
                 6: value = (value <<< 12);
                 7: value = (value <<< 14);
                 8: value = (value <<< 16);
                 9: value = (value <<< 18);
                 10: value = (value <<< 20);
                 11: value = (value <<< 22);
                 12: value = (value <<< 24);
                 13: value = (value <<< 26);
                 14: value = (value <<< 28);
                 15: value = (value <<< 30);
              endcase
        end
     endtask
     
     task track_freq;
       input [15:0] latest_freq_bin;
       reg [31:0] latest_freq;
       begin
            latest_freq = latest_freq_bin * FREQ_BIN_SIZE;
            if(latest_freq > (target_freq - freq_delta) && latest_freq < (target_freq + freq_delta)) begin
                //if timer not already enabled then enable it
                if(timer_enable == 0) begin
                    timer_enable <= 1;
                    timer_target <= timer_count + clk_count_to_recog;
                end
            end
            else begin
                timer_enable <= 0;
            end
       end
     endtask
     
     //execute dft logic
     always @(posedge bus_clk) begin: dft_logic
         reg [65:0] temp_power;
         
         if(ready_for_dft && dft_input_ready) begin
            dft_first_data_in <= 1;
            dft_size <= DFT_CONFIG;
            dft_data_in <= input_samples[0];
            cur_input_sample <= 1;
            inputing_data <= 1;
         end
     
         //dft input data
         if(inputing_data) begin
            dft_first_data_in <= 0;
            dft_data_in <= input_samples[cur_input_sample];
            
            cur_input_sample <= cur_input_sample + 1;
            if(cur_input_sample >= SAMPLES_PER_DATA-1) begin
               inputing_data <= 0;
            end
         end
         
         //stage 1 multiply (done in block design with pipeline level of 3 so other signals must be delayed)
         stage_1_p1_dft_data_valid <= dft_data_valid; //multiply pipeline 1
         stage_1_p1_dft_blk_exp <= dft_blk_exp;
         stage_1_p1_dft_first_data_out <= dft_first_data_out;
         stage_1_p2_dft_data_valid <= stage_1_p1_dft_data_valid; //multiply pipeline 2
         stage_1_p2_dft_blk_exp <= stage_1_p1_dft_blk_exp;
         stage_1_p2_dft_first_data_out <= stage_1_p1_dft_first_data_out;
         stage_1_p3_dft_data_valid <= stage_1_p2_dft_data_valid; //multiply pipeline 3
         stage_1_p3_dft_blk_exp <= stage_1_p2_dft_blk_exp;
         stage_1_p3_dft_first_data_out <= stage_1_p2_dft_first_data_out;
         
          //stage 2 add and bit shift
          temp_power = dft_re_data_out_squared + dft_im_data_out_squared;
          double_shift_value(temp_power, stage_1_p3_dft_blk_exp);
          output_power_total <= temp_power;
          stage_2_dft_data_valid <= stage_1_p3_dft_data_valid;
          stage_2_dft_first_data_out <= stage_1_p3_dft_first_data_out;
         
         //stage 3 evaluate max power frequency 
         //dft output data start
         if(stage_2_dft_first_data_out && stage_2_dft_data_valid) begin
            dft_prev_max_freq <= dft_max_freq;
            track_freq(dft_max_freq);
            
            dft_max_output <= 0; //use 0 for dc since we want to ignore it
            dft_max_freq <= 0;
            
            cur_output_sample <= 1; //start at 1 since the 0th element was collected in the this cycle and will be discarded (we don't care about DC freq)
         end
         //dft output data rest
         else if(stage_2_dft_data_valid) begin
            cur_output_sample <= cur_output_sample + 1;
            
            if(cur_output_sample < SAMPLES_PER_DATA/2 &&  output_power_total > dft_max_output) 
            begin
                dft_max_output <= output_power_total;
                dft_max_freq <= cur_output_sample;
                
            end
         end
      end

endmodule
