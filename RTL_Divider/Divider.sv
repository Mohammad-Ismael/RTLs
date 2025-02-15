 module Divider(  
   input      clk,  reset, start,
 
   input [31:0]  Dividend,  
   input [31:0]  Divisor,  

   output [31:0]  Quotient,  
   output [31:0]  Remainder,

   output RDY ,   // Take the result when 1   
   output error  
   );  
   reg          active;      // When zero, the division algorithm is doing its magic 
   reg [4:0]    c_counter;   // Counts the div cycles (32cycle)
   reg [31:0]   result, denom ,work;   
   
   wire [32:0]   sub = { work[30:0], result[31] } - denom;  

   assign error = !Divisor;  
   assign Quotient = result;  
   assign Remainder = work;  
   assign RDY = ~active;

   // The state machine  
   always @(posedge clk,posedge reset) begin  
     if (reset) begin  
       active <= 0;  
       c_counter <= 0;  
       result <= 0;  
       denom <= 0;  
       work <= 0;  
     end  
     else if(start) begin  
       if (active) begin  
         if (sub[32] == 0) begin  
           work <= sub[31:0];  
           result <= {result[30:0], 1'b1};  
         end  
         else begin  
           work <= {work[30:0], result[31]};  
           result <= {result[30:0], 1'b0};  
         end  
         if (c_counter == 0) begin  
           active <= 0;  
         end  
         c_counter <= c_counter - 5'd1;  
       end  
       else begin  
         c_counter <= 5'd31;  
         result <= Dividend;  
         denom <= Divisor;  
         work <= 32'b0;  
         active <= 1;  
       end  
     end  
   end  
 endmodule 