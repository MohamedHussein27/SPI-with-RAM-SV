module ram_top();
    bit clk;

    // clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // interface
    ram_if ramif (clk);
    // dut
    RAM dut (ramif);
    // test
    ram_tb tb (ramif);
    // monitor
    ram_monitor MONITOR (ramif);
endmodule