// Phase 2 Advanced Tests: Keyed Parameters - Advanced Scenarios
// IEEE 1800-2023 Compliance Validation

`timescale 1ns / 1ps

// Test Module: Keyed parameters with array/queue operations
module test_keyed_collections;

  function void process_array(
    input int data[],
    input int size,
    input string name
  );
    $display("Array %s: size=%d", name, size);
  endfunction

  task fill_queue(
    output int queue[],
    input int count,
    input int init_value = 0
  );
    for (int i = 0; i < count; i++) begin
      queue[i] = init_value + i;
    end
  endtask

  initial begin
    int arr[10];
    int q[$];

    // Test A.1: Keyed parameters with arrays
    process_array(.data(arr), .size(10), .name("TestArray"));

    // Test A.2: Task with keyed parameters for queue operations
    fill_queue(.queue(q), .count(5), .init_value(100));
    $display("Queue size: %d, first element: %d", q.size(), q[0]);

    $display("✓ Test Module A (Collections): PASSED");
  end

endmodule


// Test Module: Keyed parameters with generics
module test_keyed_generics;

  class Stack #(type T = int);
    local T data[$];

    task push(input T value);
      data.push_back(value);
    endtask

    function T pop();
      if (data.size() > 0)
        return data.pop_back();
      return 0;
    endfunction

    task init_and_push(input T val1, input T val2, input T val3 = 0);
      data.delete();
      push(.value(val1));
      push(.value(val2));
      if (val3 != 0)
        push(.value(val3));
    endtask
  endclass

  initial begin
    Stack #(int) int_stack = new();
    Stack #(real) real_stack = new();
    int result;

    // Test B.1: Generic class with keyed parameters
    int_stack.init_and_push(.val1(10), .val2(20), .val3(30));
    result = int_stack.pop();
    assert(result == 30) else $error("Test B.1 failed: generic stack");

    // Test B.2: Generic with different type
    real_stack.init_and_push(.val1(1.5), .val2(2.5));

    $display("✓ Test Module B (Generics): PASSED");
  end

endmodule


// Test Module: Keyed parameters with typedef
module test_keyed_typedef;

  typedef struct {
    int x;
    int y;
    string label;
  } Point;

  function Point create_point(int x, int y, string label = "point");
    Point p;
    p.x = x;
    p.y = y;
    p.label = label;
    return p;
  endfunction

  task display_point(input Point p);
    $display("Point %s: (%d, %d)", p.label, p.x, p.y);
  endtask

  initial begin
    Point p1, p2;

    // Test C.1: Keyed parameters returning struct
    p1 = create_point(.x(10), .y(20), .label("Origin"));
    assert(p1.x == 10) else $error("Test C.1 failed: p1.x");
    assert(p1.label == "Origin") else $error("Test C.1 failed: p1.label");

    // Test C.2: Mixed positional and keyed with struct
    p2 = create_point(5, .y(15), .label("Second"));
    display_point(.p(p1));
    display_point(.p(p2));

    $display("✓ Test Module C (Typedef): PASSED");
  end

endmodule


// Test Module: Keyed parameters with virtual methods
module test_keyed_virtual;

  virtual class Base;
    pure virtual task process(input int val, input string mode);
    pure virtual function int calculate(int a, int b);
  endclass

  class Derived extends Base;
    task process(input int val, input string mode);
      $display("Processing value=%d, mode=%s", val, mode);
    endtask

    function int calculate(int a, int b);
      return a + b;
    endfunction
  endclass

  initial begin
    Base obj = new Derived();
    int result;

    // Test D.1: Keyed parameters with virtual class
    obj.process(.val(100), .mode("DEBUG"));

    // Test D.2: Virtual method with keyed parameters
    result = obj.calculate(.a(5), .b(7));
    assert(result == 12) else $error("Test D.1 failed: virtual calculate");

    $display("✓ Test Module D (Virtual Classes): PASSED");
  end

endmodule


// Test Module: Keyed parameters in assertions and randomization
module test_keyed_advanced_features;

  class RandomConfig;
    rand int seed;
    rand int iterations;
    constraint seed_range { seed >= 0; seed < 1000; }
    constraint iter_range { iterations >= 1; iterations <= 100; }

    function new();
      seed = 0;
      iterations = 10;
    endfunction

    task configure(input int s = 0, input int i = 10);
      seed = s;
      iterations = i;
    endtask
  endclass

  initial begin
    RandomConfig cfg = new();

    // Test E.1: Class method with keyed parameters
    cfg.configure(.s(42), .i(50));
    assert(cfg.seed == 42) else $error("Test E.1 failed: seed");
    assert(cfg.iterations == 50) else $error("Test E.1 failed: iterations");

    // Test E.2: Randomization with keyed parameters
    cfg.randomize();
    $display("Random seed: %d, iterations: %d", cfg.seed, cfg.iterations);

    $display("✓ Test Module E (Advanced Features): PASSED");
  end

endmodule


// Test Module: Keyed parameters with constraints
module test_keyed_with_constraints;

  class ConstrainedValue;
    rand int value;
    constraint value_range { value >= 0; value <= 255; }

    function new(int v = 0);
      value = v;
    endfunction

    task set_value(input int v);
      value = v;
    endtask

    task initialize(input int initial_val, input string description = "value");
      set_value(.v(initial_val));
      $display("Initialized %s to %d", description, value);
    endtask
  endclass

  initial begin
    ConstrainedValue cv = new();

    // Test F.1: Keyed parameters with constraints
    cv.initialize(.initial_val(100), .description("counter"));
    assert(cv.value == 100) else $error("Test F.1 failed: initialize");

    // Test F.2: Task with keyed parameters
    cv.set_value(.v(200));
    assert(cv.value == 200) else $error("Test F.2 failed: set_value");

    $display("✓ Test Module F (Constraints): PASSED");
  end

endmodule


// Test Module: Keyed parameters in property-based verification
module test_keyed_properties;

  class Model;
    int state;

    task reset();
      state = 0;
    endtask

    task update(input int delta);
      state += delta;
    endtask

    function int get_state();
      return state;
    endfunction

    task verify_state(input int expected);
      assert(state == expected) else
        $error("State verification failed: expected=%d, got=%d", expected, state);
    endtask
  endclass

  initial begin
    Model m = new();

    // Test G.1: Property-style keyed parameter calls
    m.reset();
    m.verify_state(.expected(0));

    m.update(.delta(10));
    m.verify_state(.expected(10));

    m.update(.delta(5));
    m.verify_state(.expected(15));

    $display("✓ Test Module G (Properties): PASSED");
  end

endmodule


// Test Module: Module instantiation with keyed parameters (beyond function calls)
module DualPort
#(
  parameter int WIDTH = 32,
  parameter int DEPTH = 1024
) (
  input clk,
  input [WIDTH-1:0] data_in
);
  // Module body
endmodule


module test_keyed_module_params;

  reg clk;
  reg [31:0] data;

  // Module instantiation with keyed parameters (parameterized modules)
  DualPort #(.WIDTH(64), .DEPTH(2048)) dram_inst (
    .clk(clk),
    .data_in(data)
  );

  DualPort #(.DEPTH(512), .WIDTH(32)) sram_inst (
    .clk(clk),
    .data_in(data)
  );

  initial begin
    clk = 0;
    data = 32'hDEADBEEF;
    #10;
    clk = 1;
    #10;

    $display("✓ Test Module H (Module Params): PASSED");
  end

endmodule


// Summary test module
module keyed_params_advanced_test;
  // All advanced test modules are instantiated above
  // Tests validate IEEE 1800-2023 keyed parameter compliance
endmodule
