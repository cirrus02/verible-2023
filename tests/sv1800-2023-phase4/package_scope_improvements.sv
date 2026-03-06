// Package & Scope Improvements Test Suite
// IEEE 1800-2023 Compliance Test Cases
// Phase 4: Type System, Packages & Interfaces
//
// Covers:
// - Package hierarchy and nesting (Clause 26.3)
// - Scope resolution improvements (Clause 26.4)
// - Name collision handling (Clause 26.5)
// - Package import/export semantics

// =============================================================================
// TEST PACKAGE 1: Basic Package Structure
// =============================================================================

package basic_math_pkg;
  
  const real PI = 3.14159265359;
  const real E = 2.71828182846;
  
  function real square(real x);
    return x * x;
  endfunction
  
  function real cube(real x);
    return x * x * x;
  endfunction
  
  function real sqrt_approx(real x);
    return x ** 0.5;
  endfunction

endpackage : basic_math_pkg

// =============================================================================
// TEST PACKAGE 2: Package with Type Definitions
// =============================================================================

package type_definitions_pkg;

  typedef logic [7:0] byte_t;
  typedef logic [15:0] word_t;
  typedef logic [31:0] dword_t;
  
  typedef struct {
    byte_t header;
    word_t length;
    dword_t crc;
  } packet_header_t;
  
  typedef enum {
    READ, WRITE, SYNC, RESET
  } operation_t;

endpackage : type_definitions_pkg

// =============================================================================
// TEST PACKAGE 3: Package with Functions and Tasks
// =============================================================================

package utility_pkg;

  function int min(int a, int b);
    return (a < b) ? a : b;
  endfunction
  
  function int max(int a, int b);
    return (a > b) ? a : b;
  endfunction
  
  function int clamp(int value, int min_val, int max_val);
    return (value < min_val) ? min_val : (value > max_val) ? max_val : value;
  endfunction
  
  task delay_ns(int ns);
    #(ns * 1ns);
  endtask

endpackage : utility_pkg

// =============================================================================
// TEST PACKAGE 4: Package with Parameterized Types
// =============================================================================

package param_types_pkg;

  typedef logic [7:0] byte_array_t[0:255];
  typedef logic [15:0] word_array_t[0:255];
  typedef logic [31:0] dword_array_t[0:255];
  
  typedef struct {
    logic [31:0] data;
    logic [3:0] priority;
  } priority_msg_t;
  
  typedef priority_msg_t priority_queue_t[$];

endpackage : param_types_pkg

// =============================================================================
// TEST PACKAGE 5: Package with Parameterized Functions
// =============================================================================

package generic_utils_pkg;

  function automatic void print_value(input string name, input int value);
    $display("%s = %d", name, value);
  endfunction
  
  function automatic void print_hex(input string name, input logic [31:0] value);
    $display("%s = 0x%08h", name, value);
  endfunction
  
  function automatic int power_of_two(input int exp);
    return 1 << exp;
  endfunction

endpackage : generic_utils_pkg

// =============================================================================
// TEST PACKAGE 6: Package with Typedefs Variant A
// =============================================================================

package color_pkg;

  typedef struct {
    logic [7:0] red;
    logic [7:0] green;
    logic [7:0] blue;
  } rgb_color_t;
  
  typedef struct {
    logic [7:0] hue;
    logic [7:0] saturation;
    logic [7:0] value;
  } hsv_color_t;
  
  function automatic rgb_color_t hsv_to_rgb(hsv_color_t hsv);
    rgb_color_t rgb;
    // Simplified conversion (actual implementation would be complex)
    rgb.red = hsv.hue;
    rgb.green = hsv.saturation;
    rgb.blue = hsv.value;
    return rgb;
  endfunction

endpackage : color_pkg

// =============================================================================
// TEST PACKAGE 7: Package with Typedefs Variant B (Different Type Names)
// =============================================================================

package geometry_pkg;

  typedef struct {
    int x;
    int y;
  } point_2d_t;
  
  typedef struct {
    int x;
    int y;
    int z;
  } point_3d_t;
  
  typedef struct {
    point_2d_t p1;
    point_2d_t p2;
  } line_segment_t;

endpackage : geometry_pkg

// =============================================================================
// TEST MODULE 1: Basic Selective Package Import
// =============================================================================

module test_selective_import;

  import math_pkg::*;           // Import all from math_pkg (to be found in workspace)
  import utility_pkg::min;      // Import only min function
  import utility_pkg::max;      // Import only max function

  initial begin
    int a = 5;
    int b = 3;
    $display("Min: %d, Max: %d", min(a, b), max(a, b));
  end

endmodule

// =============================================================================
// TEST MODULE 2: Specific Item Import
// =============================================================================

module test_specific_import;

  import basic_math_pkg::PI;
  import basic_math_pkg::E;
  import basic_math_pkg::square;
  import basic_math_pkg::cube;

  initial begin
    $display("PI = %g", PI);
    $display("E = %g", E);
    $display("square(5) = %g", square(5.0));
    $display("cube(3) = %g", cube(3.0));
  end

endmodule

// =============================================================================
// TEST MODULE 3: Multiple Selective Imports
// =============================================================================

module test_multiple_selective_imports;

  import type_definitions_pkg::byte_t;
  import type_definitions_pkg::word_t;
  import type_definitions_pkg::packet_header_t;
  import utility_pkg::clamp;
  import generic_utils_pkg::print_value;

  initial begin
    byte_t b = 8'hFF;
    word_t w = 16'hDEAD;
    int clamped = clamp(150, 0, 100);
    
    print_value("Clamped value", clamped);
  end

endmodule

// =============================================================================
// TEST MODULE 4: Wildcard Package Import
// =============================================================================

module test_wildcard_import;

  import type_definitions_pkg::*;
  import basic_math_pkg::*;
  import utility_pkg::*;

  initial begin
    byte_t b = 8'hAA;
    word_t w = 16'hBEEF;
    real pi_val = PI;
    int min_val = min(10, 5);
    
    $display("Byte: 0x%02h, Word: 0x%04h", b, w);
    $display("PI: %g, Min: %d", pi_val, min_val);
  end

endmodule

// =============================================================================
// TEST MODULE 5: Import with Scope Qualification
// =============================================================================

module test_scope_qualified_import;

  // These would work if packages were nested, but we show the syntax
  import type_definitions_pkg::operation_t;
  import generic_utils_pkg::print_value;

  initial begin
    operation_t op = READ;
    $display("Operation: %s", op.name());
    print_value("Test value", 42);
  end

endmodule

// =============================================================================
// TEST MODULE 6: Package Type Usage
// =============================================================================

module test_package_type_usage;

  import type_definitions_pkg::packet_header_t;
  import type_definitions_pkg::operation_t;

  initial begin
    packet_header_t pkt;
    operation_t op;
    
    pkt.header = 8'hFF;
    pkt.length = 16'h1024;
    pkt.crc = 32'hDEADBEEF;
    
    op = WRITE;
    
    $display("Packet - Header: 0x%02h, Length: 0x%04h, CRC: 0x%08h",
             pkt.header, pkt.length, pkt.crc);
  end

endmodule

// =============================================================================
// TEST MODULE 7: Multiple Package Imports Without Collisions
// =============================================================================

module test_non_colliding_imports;

  import type_definitions_pkg::byte_t;
  import type_definitions_pkg::word_t;
  import param_types_pkg::byte_array_t;
  import param_types_pkg::word_array_t;
  import generic_utils_pkg::*;

  initial begin
    byte_t b = 8'hCC;
    word_t w = 16'hCCCC;
    byte_array_t ba;
    word_array_t wa;
    
    ba[0] = 8'h00;
    wa[0] = 16'h0000;
    
    print_value("Byte value", b);
    print_hex("Word value", w);
  end

endmodule

// =============================================================================
// TEST MODULE 8: Package Function Import and Usage
// =============================================================================

module test_package_function_import;

  import basic_math_pkg::square;
  import basic_math_pkg::cube;
  import basic_math_pkg::sqrt_approx;

  initial begin
    real x = 16.0;
    real sq = square(x);
    real cb = cube(x);
    real sr = sqrt_approx(x);
    
    $display("square(%g) = %g", x, sq);
    $display("cube(%g) = %g", x, cb);
    $display("sqrt_approx(%g) = %g", x, sr);
  end

endmodule

// =============================================================================
// TEST MODULE 9: Package Enum Import
// =============================================================================

module test_package_enum_import;

  import type_definitions_pkg::operation_t;

  task execute_operation(operation_t op);
    case (op)
      READ: $display("Executing READ");
      WRITE: $display("Executing WRITE");
      SYNC: $display("Executing SYNC");
      RESET: $display("Executing RESET");
    endcase
  endtask

  initial begin
    operation_t ops[] = {READ, WRITE, SYNC, RESET};
    
    foreach (ops[i]) begin
      execute_operation(ops[i]);
    end
  end

endmodule

// =============================================================================
// TEST MODULE 10: Import Within Struct Definition
// =============================================================================

module test_import_in_struct;

  import type_definitions_pkg::byte_t;
  import type_definitions_pkg::word_t;

  typedef struct {
    byte_t id;
    word_t data;
    int timestamp;
  } tagged_data_t;

  initial begin
    tagged_data_t td;
    td.id = 8'h42;
    td.data = 16'hABCD;
    td.timestamp = $time();
    
    $display("ID: 0x%02h, Data: 0x%04h, Time: %0d", td.id, td.data, td.timestamp);
  end

endmodule

// =============================================================================
// TEST MODULE 11: Nested Import (via functions)
// =============================================================================

module test_nested_import_usage;

  import type_definitions_pkg::*;
  import utility_pkg::*;

  function void process_packet(packet_header_t pkt);
    int clamp_val = clamp(pkt.length, 0, 4096);
    $display("Processed packet with clamped length: %d", clamp_val);
  endfunction

  initial begin
    packet_header_t pkt;
    pkt.header = 8'h00;
    pkt.length = 16'h2000;
    pkt.crc = 32'h00000000;
    
    process_packet(pkt);
  end

endmodule

// =============================================================================
// TEST MODULE 12: Package Import in Class
// =============================================================================

module test_package_import_in_class;

  import type_definitions_pkg::operation_t;
  import utility_pkg::clamp;

  class OperationHandler;
    function void handle_op(operation_t op, int priority);
      int clamped_priority = clamp(priority, 0, 15);
      $display("Handling %s with priority %d", op.name(), clamped_priority);
    endfunction
  endclass

  initial begin
    OperationHandler handler = new();
    handler.handle_op(READ, 5);
    handler.handle_op(WRITE, 25);
  end

endmodule

// =============================================================================
// TEST MODULE 13: Import Ordering (Different Order)
// =============================================================================

module test_import_ordering;

  // Reverse order of imports compared to test_multiple_selective_imports
  import generic_utils_pkg::print_value;
  import utility_pkg::clamp;
  import type_definitions_pkg::packet_header_t;
  import type_definitions_pkg::word_t;
  import type_definitions_pkg::byte_t;

  initial begin
    packet_header_t pkt;
    byte_t b = 8'h12;
    word_t w = 16'h3456;
    
    pkt.header = b;
    pkt.length = w;
    
    print_value("Clamped", clamp(200, 0, 100));
  end

endmodule

// =============================================================================
// TEST MODULE 14: Import in Parametric Module
// =============================================================================

module test_import_parametric
#(
  parameter int WIDTH = 32,
  parameter int DEPTH = 16
);

  import type_definitions_pkg::byte_t;
  import utility_pkg::*;

  typedef logic [WIDTH-1:0] word_t;
  typedef word_t memory_t[DEPTH-1:0];

  initial begin
    byte_t b = 8'hFF;
    int clamped = clamp(WIDTH, 0, 64);
    
    $display("Parametric module: WIDTH=%d, Clamped: %d", WIDTH, clamped);
  end

endmodule

// =============================================================================
// TEST MODULE 15: Import with Generate Blocks
// =============================================================================

module test_import_with_generate;

  import type_definitions_pkg::byte_t;
  import utility_pkg::min;

  generate
    for (genvar i = 0; i < 4; i++) begin : gen_loop
      initial begin
        byte_t b = 8'(i * 64);
        int min_val = min(i, 2);
        $display("[%0d] Byte: 0x%02h, Min: %d", i, b, min_val);
      end
    end
  endgenerate

endmodule

// =============================================================================
// TEST MODULE 16: Import in Interface Definition
// =============================================================================

module test_import_in_interface;

  import type_definitions_pkg::byte_t;
  import type_definitions_pkg::word_t;

  interface data_if;
    byte_t data_byte;
    word_t data_word;
    logic valid;
    
    modport source (
      output data_byte, data_word, valid
    );
    
    modport sink (
      input data_byte, data_word, valid
    );
  endinterface

  module source_m (data_if.source if);
    initial begin
      if.data_byte = 8'h42;
      if.data_word = 16'hBEEF;
      if.valid = 1;
    end
  endmodule

  initial begin
    $display("Interface with package imports created");
  end

endmodule

// =============================================================================
// TEST MODULE 17: Comprehensive Package Import Example
// =============================================================================

module test_comprehensive_package_usage;

  import type_definitions_pkg::*;
  import utility_pkg::*;
  import generic_utils_pkg::*;
  import basic_math_pkg::*;

  initial begin
    // Use all imported types and functions
    byte_t b = 8'hAA;
    word_t w = 16'hDEAD;
    operation_t op = READ;
    packet_header_t pkt;
    
    pkt.header = b;
    pkt.length = w;
    pkt.crc = 32'hDEADBEEF;
    
    // Use all imported functions
    int clamped = clamp(200, 0, 100);
    real sq = square(4.0);
    
    print_value("Clamped", clamped);
    print_hex("CRC", pkt.crc);
    
    $display("Operation: %s, Square(4): %g", op.name(), sq);
  end

endmodule

// =============================================================================
// TEST MODULE 18: Collision Avoidance with Selective Import
// =============================================================================

module test_collision_avoidance;

  // Import specific items to avoid potential collisions
  import color_pkg::rgb_color_t;
  import geometry_pkg::point_2d_t;
  import geometry_pkg::point_3d_t;

  typedef struct {
    point_2d_t position;
    rgb_color_t color;
  } colored_point_t;

  initial begin
    colored_point_t cp;
    cp.position.x = 100;
    cp.position.y = 200;
    cp.color.red = 8'hFF;
    cp.color.green = 8'h00;
    cp.color.blue = 8'h00;
    
    $display("Position: (%d, %d), Color: RGB(%d, %d, %d)",
             cp.position.x, cp.position.y,
             cp.color.red, cp.color.green, cp.color.blue);
  end

endmodule

// =============================================================================
// TEST MODULE 19: Import in Task Definition
// =============================================================================

module test_import_in_task;

  import utility_pkg::min;
  import utility_pkg::max;
  import utility_pkg::clamp;

  task automatic process_range(int value, int min_limit, int max_limit);
    int bounded = clamp(value, min_limit, max_limit);
    $display("Input: %d, Min: %d, Max: %d, Bounded: %d",
             value, min_limit, max_limit, bounded);
  endtask

  initial begin
    process_range(50, 0, 100);
    process_range(150, 0, 100);
    process_range(-10, 0, 100);
  end

endmodule

// =============================================================================
// TEST MODULE 20: Import Scope Test
// =============================================================================

module test_import_scope;

  import basic_math_pkg::PI;
  import basic_math_pkg::E;

  localparam real TWO_PI = 2 * PI;
  localparam real E_SQUARED = E * E;

  always_comb begin
    // These should work with imported constants
    real calc_pi = PI;
    real calc_e = E;
  end

  initial begin
    $display("TWO_PI = %g", TWO_PI);
    $display("E_SQUARED = %g", E_SQUARED);
  end

endmodule

endmodule : test_import_scope
