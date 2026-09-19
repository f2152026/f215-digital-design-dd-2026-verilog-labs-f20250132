// tb.v
module tb;
    reg [3:0] t_a;
    reg [3:0] t_b;
    reg t_op;
    wire [3:0] t_result;
    
    reg [3:0] exp_result;
    integer errors = 0;

    alu DUT (
        .a(t_a),
        .b(t_b),
        .op(t_op),
        .result(t_result)
    );


    string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

    initial begin
        t_a = 4'd5; t_b = 4'd3; t_op = 1'b0; // Add: 5 + 3 = 8
        #10;
        check_result();

        t_op = 1'b1;                         // Sub: 5 - 3 = 2 
        #10;
        check_result();                      // If bug exists, this will fail (output holds 8)

        t_a = 4'd10; t_b = 4'd4; t_op = 1'b1; // Sub: 10 - 4 = 6
        #10;
        check_result();                      // If bug exists, uses stale internal registers

        t_a = 4'd7; t_b = 4'd1;  t_op = 1'b1; // Sub: 7 - 1 = 6
        #10;
        check_result();                      // If bug exists, uses stale internal registers

        t_a = 4'd2; t_b = 4'd5;  t_op = 1'b0; // Add: 2 + 5 = 7
        #10;
        check_result();

        t_a = 4'd15; t_b = 4'd15; t_op = 1'b1; // Sub: 15 - 15 = 0
        #10;
        check_result();
        
        if (errors == 0)
            $display("SUCCESS: All tests passed cleanly!");
        else
            $display("FAILED: %0d errors found.", errors);
            
        $finish;
    end

    // Self-checking task
    task check_result;
        begin
            // Compute expected result
            if (t_op == 1'b0)
                exp_result = t_a + t_b;
            else
                exp_result = t_a - t_b;

            // Check against actual DUT result
            if (t_result !== exp_result) begin
                $display("FAIL at time %0t: A=%d B=%d op=%b | got=%d expected=%d",
                         $time, t_a, t_b, t_op, t_result, exp_result);
                errors = errors + 1;
            end
        end
    endtask

endmodule