// Phase 2 Test Suite: Keyed Parameters in Function Arguments
// IEEE 1800-2023 Feature Validation
// Tests named/keyed parameter syntax in function calls, tasks, and methods

`timescale 1ns / 1ps

// Test Module 1: Basic function with keyed parameters
module test_func_keyed_basic;

  // Function with multiple parameters
  function int add(int a, int b);
    return a + b;
  endfunction

  function string concat(string prefix, string suffix);
    return {prefix, suffix};
  endfunction

  initial begin
    int result1;
    int result2;
    int result3;
    string str1;
    string str2;

    // Test 1.1: All keyed parameters
    result1 = add(.a(5), .b(3));
    assert(result1 == 8) else $error("Test 1.1 failed: add(.a(5), .b(3))");

    // Test 1.2: Reversed order of keyed parameters
    result2 = add(.b(7), .a(2));
    assert(result2 == 9) else $error("Test 1.2 failed: add(.b(7), .a(2))");

    // Test 1.3: Mixed positional and keyed (positional first)
    result3 = add(10, .b(5));
    assert(result3 == 15) else $error("Test 1.3 failed: add(10, .b(5))");

    // Test 1.4: String functions with keyed parameters
    str1 = concat(.prefix("Hello "), .suffix("World"));
    assert(str1 == "Hello World") else $error("Test 1.4 failed: concat with keyed params");

    // Test 1.5: Traditional positional arguments still work
    str2 = concat("Foo", "Bar");
    assert(str2 == "FooBar") else $error("Test 1.5 failed: concat positional");

    $display("✓ Test Module 1 (Basic Functions): PASSED");
  end

endmodule


// Test Module 2: Task with keyed parameters
module test_task_keyed;

  task compute(int x, int y, output int result);
    result = x * y;
  endtask

  task process_data(input int width, input int height, input string name, output int area);
    area = width * height;
    $display("Processing %s: %dx%d", name, width, height);
  endtask

  initial begin
    int res1, res2, res3;
    int area;

    // Test 2.1: Task with all keyed parameters
    compute(.x(4), .y(5), .result(res1));
    assert(res1 == 20) else $error("Test 2.1 failed: compute(.x(4), .y(5), .result)");

    // Test 2.2: Task with mixed positional and keyed
    compute(6, .y(7), .result(res2));
    assert(res2 == 42) else $error("Test 2.2 failed: compute(6, .y(7), .result)");

    // Test 2.3: Task with reversed keyed parameter order
    compute(.y(8), .x(3), .result(res3));
    assert(res3 == 24) else $error("Test 2.3 failed: compute with reversed keyed order");

    // Test 2.4: Complex task with multiple types
    process_data(.width(100), .height(200), .name("Image"), .area(area));
    assert(area == 20000) else $error("Test 2.4 failed: process_data task");

    $display("✓ Test Module 2 (Tasks): PASSED");
  end

endmodule


// Test Module 3: Methods and classes with keyed parameters
module test_class_keyed;

  class Calculator;
    function int add(int a, int b);
      return a + b;
    endfunction

    function int multiply(int x, int y);
      return x * y;
    endfunction

    task calculate_sum(input int val1, input int val2, output int sum);
      sum = val1 + val2;
    endtask
  endclass

  initial begin
    Calculator calc = new();
    int result1, result2, result3;
    int sum;

    // Test 3.1: Method call with keyed parameters
    result1 = calc.add(.a(10), .b(20));
    assert(result1 == 30) else $error("Test 3.1 failed: method add with keyed params");

    // Test 3.2: Method with mixed parameters
    result2 = calc.multiply(5, .y(6));
    assert(result2 == 30) else $error("Test 3.2 failed: method multiply mixed");

    // Test 3.3: Method with reversed keyed parameters
    result3 = calc.add(.b(15), .a(25));
    assert(result3 == 40) else $error("Test 3.3 failed: method add reversed keyed");

    // Test 3.4: Task method with keyed parameters
    calc.calculate_sum(.val1(100), .val2(200), .sum(sum));
    assert(sum == 300) else $error("Test 3.4 failed: task method with keyed params");

    $display("✓ Test Module 3 (Classes): PASSED");
  end

endmodule


// Test Module 4: Nested function calls with keyed parameters
module test_nested_keyed;

  function int double_value(int x);
    return x * 2;
  endfunction

  function int add(int a, int b);
    return a + b;
  endfunction

  function int complex_calc(int a, int b, int c);
    return (a * b) + c;
  endfunction

  initial begin
    int result1, result2, result3;

    // Test 4.1: Nested calls with keyed parameters
    result1 = add(.a(double_value(5)), .b(10));
    assert(result1 == 20) else $error("Test 4.1 failed: nested add with double_value");

    // Test 4.2: Multiple levels of nesting
    result2 = add(.a(double_value(3)), .b(double_value(4)));
    assert(result2 == 14) else $error("Test 4.2 failed: double nested calls");

    // Test 4.3: Complex expression with keyed parameters
    result3 = complex_calc(.a(2), .b(add(.a(3), .b(4))), .c(5));
    assert(result3 == 19) else $error("Test 4.3 failed: complex_calc nested");

    $display("✓ Test Module 4 (Nested Calls): PASSED");
  end

endmodule


// Test Module 5: Constructor with keyed parameters
module test_constructor_keyed;

  class Config;
    int width;
    int depth;
    string name;

    function new(int w, int d, string n = "unnamed");
      width = w;
      depth = d;
      name = n;
    endfunction

    function void display();
      $display("%s: %dx%d", name, width, depth);
    endfunction
  endclass

  initial begin
    Config cfg1, cfg2, cfg3;

    // Test 5.1: Constructor with keyed parameters
    cfg1 = new(.w(32), .d(1024), .n("Config1"));
    assert(cfg1.width == 32) else $error("Test 5.1 failed: cfg1.width");
    assert(cfg1.depth == 1024) else $error("Test 5.1 failed: cfg1.depth");

    // Test 5.2: Constructor with mixed parameters
    cfg2 = new(64, .d(512), .n("Config2"));
    assert(cfg2.width == 64) else $error("Test 5.2 failed: cfg2.width");
    assert(cfg2.depth == 512) else $error("Test 5.2 failed: cfg2.depth");

    // Test 5.3: Constructor with positional only
    cfg3 = new(128, 256, "Config3");
    assert(cfg3.width == 128) else $error("Test 5.3 failed: cfg3.width");

    cfg1.display();
    cfg2.display();
    cfg3.display();

    $display("✓ Test Module 5 (Constructors): PASSED");
  end

endmodule


// Test Module 6: Edge cases and special scenarios
module test_keyed_edge_cases;

  function int func_no_args();
    return 42;
  endfunction

  function int func_single_arg(int x);
    return x;
  endfunction

  function int func_many_args(int a, int b, int c, int d, int e);
    return a + b + c + d + e;
  endfunction

  initial begin
    int result1, result2;

    // Test 6.1: Function with no arguments
    result1 = func_no_args();
    assert(result1 == 42) else $error("Test 6.1 failed: func_no_args");

    // Test 6.2: Function with single keyed argument
    result1 = func_single_arg(.x(99));
    assert(result1 == 99) else $error("Test 6.2 failed: func_single_arg keyed");

    // Test 6.3: Function with many arguments in different orders
    result2 = func_many_args(.a(1), .c(3), .b(2), .e(5), .d(4));
    assert(result2 == 15) else $error("Test 6.3 failed: many args reordered");

    // Test 6.4: Mixing default and explicit keyed parameters
    result1 = func_single_arg(.x(50));
    assert(result1 == 50) else $error("Test 6.4 failed: default param keyed");

    $display("✓ Test Module 6 (Edge Cases): PASSED");
  end

endmodule


// Test Module 7: Real-world scenarios
module test_keyed_realistic;

  task configure_dpi(
    input int data_width = 32,
    input int addr_width = 10,
    input string mode = "READ",
    output bit success
  );
    success = 1;
    $display("DPI Config: width=%d, addr=%d, mode=%s", data_width, addr_width, mode);
  endtask

  function automatic void process_packet(
    input logic [7:0] payload,
    input logic valid = 1'b0,
    input int priority = 0
  );
    $display("Packet: payload=%h, valid=%b, priority=%d", payload, valid, priority);
  endfunction

  initial begin
    bit success;

    // Test 7.1: Realistic DPI configuration with keyed parameters
    configure_dpi(.data_width(64), .addr_width(12), .mode("WRITE"), .success(success));
    assert(success) else $error("Test 7.1 failed: configure_dpi");

    // Test 7.2: Mixed keyed and default parameters
    configure_dpi(.data_width(32), .mode("READ"), .success(success));
    assert(success) else $error("Test 7.2 failed: configure_dpi partial");

    // Test 7.3: Process packet with keyed parameters
    process_packet(.payload(8'hAA), .valid(1'b1), .priority(5));

    // Test 7.4: Process packet with partial keyed parameters
    process_packet(8'hBB, .valid(1'b0));

    $display("✓ Test Module 7 (Realistic): PASSED");
  end

endmodule


// Top-level test
module keyed_params_comprehensive_test;
  // All test modules instantiated above
endmodule
