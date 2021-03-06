
////////////////////
///////simpleadder TB 
///////////////////

module simpleadder_directtb_driver ();
	//declare inputs as logic
		
		   logic  clk;
		   logic en_i;
		   logic ina;
		   logic inb;

		  
	//declare outputs as logic
		    logic en_o;
			logic out ;
		   
		   
	//instantiate DUT and connect
	simpleadder DUT ( .clk(clk), .en_i(en_i), .ina(ina), .inb(inb), .en_o(en_o), .out(out));
	
	
	//create input mailbox
	 mailbox in_mbox= new(); 
	 
		
	
	
	//create output mailbox
		mailbox out_mbox= new(); 
 
	 
	 /************************************************************************************/
	 
	 task drive (int count);
		 
		
		$display ("************T= %0d DRIVER STARTS ***********", $time );
		repeat(count) begin
		@(posedge clk);	
		en_i <= 1'b1;
		ina  <= $random ;
		inb  <= $random ;
		
		$display("*****APPLYING RANDOM INPUTS A= %0d \t B= %0d \t at TIME %0d *******",ina, inb, $time);
		
		@ (posedge clk);
		en_i <= 1'b0;
		ina  <= $random ;
		inb  <= $random ;
		$display("****APPLYING RANDOM INPUTS A= %0d \t B= %0d \t at TIME %0d ****",ina, inb, $time);
		@ (posedge clk);
		@ (posedge clk);
		@ (posedge clk);	
		@ (posedge clk);
		@ (posedge clk);
		@ (posedge clk);
		
		$display("------------- 0.0  WAIT FOR OUTPUT  0.0--------------"); 
	

		end
	endtask

	/**************************MONITORS*******************************/

	logic [2:0] Temp_out; 

	task monitor_output();
		forever 
			begin
			
			@ (posedge clk  iff en_o == 1 );
				$display ("*****STARTS OF MONITOR OUTPUT @ %0d \t " ,$time ); 
				   // 10 11 >> 101
						
				Temp_out<= out ;   // 1 
			  @(posedge clk);
			  Temp_out = Temp_out <<1 ; // 10 
			  Temp_out[0] = Temp_out[0] | out ; //10 
			   
								
			  @(posedge clk);
			  Temp_out = Temp_out <<1 ; // 100 
			  Temp_out[0] = Temp_out[0] | out ;  //101
			   /************************************************/
			   out_mbox.put(Temp_out);
				$display ("***** THE OUTPUT= %0d PUT IN THE MAILBOX **********", Temp_out); 
		

			end
	endtask 
	
     /***************************************************************/

	task monitor_input();
		
		logic [1:0] IN_A; 
		logic [1:0] IN_B; 
		forever begin
		
			IN_A=0; 
			IN_B=0; 
		@(posedge clk iff en_i == 1 )	
			$display ("*****STARTS OF MONITOR INPUT  @ %0d \t *******" ,$time ); 
			IN_A[0]=ina; 
			IN_B[0]=inb ; 
			$display("THE VALUE OF THE FIRST INPUT A  = %0d", ina);
			$display("THE VALUE OF THE SECUND  INPUT B = %0d", inb);
		@(posedge clk ) 
			IN_A = IN_A<<1 ; 
			IN_B = IN_B <<1 ; 
			IN_A[0]= IN_A[0] | ina; 
			IN_B[0]= IN_B[0] | inb ; 

			$display("THE VALUE OF THE FIRST INPUT A  = %0d", ina);
			$display("THE VALUE OF THE SECUND  INPUT B = %0d", inb);
			in_mbox.put(IN_A);
			$display("THE VALUE OF THE FIRST INPUT A PUT IN THE MAIL BOX IS   = %0d",IN_A );
			
			in_mbox.put(IN_B);
			$display("THE VALUE OF THE SECUND  I/P  B PUT IN THE MAIL BOX IS   = %0d",IN_B );
			
			$display("*****************DATA IS SUCCESSFULLY PUT IN THE MAILBOX 0.0**********************" );
			


		end
	endtask 
	
	/************************************CHECKER**************************************/


	task check_output();
		
		logic [1:0] B_MAIL , A_MAIL  ; 
		logic [2:0] out_mail ; 
		
		
		$display(" **** OUTPUT CHECKER STARTS 0.0  ****** @ %0d", $time);
		forever 
			begin
				$display(" 0.0 _______ 0.0");
				
				in_mbox.get( A_MAIL );
							$display("THE VALUE OF THE FIRST INPUT A FROM MAIL  = %0d",A_MAIL);

				in_mbox.get( B_MAIL );
							$display("THE VALUE OF THE SECUND  I/P  B FROM  THE MAIL BOX IS   = %0d",B_MAIL );
				
				out_mbox.get(out_mail);
							$display ("***** THE OUTPUT= %0d GOT FROM THE MAILBOX **********", out_mail); 
		
				if (out_mail ==  A_MAIL + B_MAIL )
					begin 
					
						$display ("*************************** 0.0 *******************************"); 
						$display ("----------------- GOOD  !!! ADDER  WORKS  SUCCESSFULLY --------------"); 
						$display (">>>>>> %0d + %0d = %0d ",  A_MAIL ,B_MAIL , out_mail  ); 
					end
				else 
					begin 
									$display ("******** ERROR !!! ADDER  DON'T WORK RIGHT  *********"); 
									$display ("******%0d + %0d = %0d  ??? ********",  A_MAIL ,B_MAIL , out_mail  ); 	
					end 
				
				 
			
				
			
			
			
		 	
		  end
	endtask

	initial begin
	
	
	
	
	/***********************************************************/
		//fork 4 tasks
		
		fork
		 drive (6);
		 monitor_output();
		 monitor_input();
		 check_output();
		join

	end

	//always block or initial -> generate clk
	initial 
	
   begin 	
		clk =1; 
		


	end 
always #5 clk =~clk ; 
		
	


endmodule