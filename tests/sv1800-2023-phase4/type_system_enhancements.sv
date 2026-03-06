// Type System Enhancements Test Suite
// IEEE 1800-2023 Compliance Test Cases
// Phase 4: Type System, Packages & Interfaces
//
// Covers:
// - Union type enhancements (Clause 6.3)
// - Structure field constraints (Clause 7.4)
// - Type composition improvements (Clauses 6-8)
// - Type parameterization and aliasing

// =============================================================================
// TEST MODULE 1: Simple Union Type Declarations
// =============================================================================

module test_simple_unions;

  // Test Case 1.1: Basic union declaration
  typedef union {
    int int_val;
    real real_val;
  } simple_union_t;

  // Test Case 1.2: Union with multiple data types
  typedef union {
    logic [7:0] byte_val;
    logic [15:0] word_val;
    logic [31:0] dword_val;
  } data_union_t;

  // Test Case 1.3: Union inside struct
  typedef struct {
    logic [7:0] header;
    union {
      int addr;
      logic [31:0] data;
    } payload;
  } packet_t;

  initial begin
    simple_union_t su;
    data_union_t du;
    packet_t pkt;
    
    su.int_val = 42;
    su.real_val = 3.14;
    
    du.byte_val = 8'hAA;
    du.word_val = 16'hDEAD;
    
    pkt.header = 8'hFF;
    pkt.payload.addr = 0xDEADBEEF;
  end

endmodule

// =============================================================================
// TEST MODULE 2: Tagged Union Types
// =============================================================================

module test_tagged_unions;

  // Test Case 2.1: Simple tagged union
  typedef union tagged {
    int int_val;
    real real_val;
  } simple_tagged_union_t;

  // Test Case 2.2: Tagged union with strings
  typedef union tagged {
    int signed int_val;
    real real_val;
    string str_val;
  } tagged_union_t;

  // Test Case 2.3: Tagged union with arrays
  typedef union tagged {
    int int_array[int];
    logic [7:0] byte_array[$];
  } array_tagged_union_t;

  // Test Case 2.4: Nested tagged unions
  typedef union tagged {
    struct {
      int x;
      int y;
    } coord;
    struct {
      real r;
      real theta;
    } polar;
  } point_union_t;

  // Test Case 2.5: Tagged union with void
  typedef union tagged {
    void null;
    int value;
    string message;
  } result_union_t;

  initial begin
    simple_tagged_union_t stu = tagged_union_t'(
      tagged int_val '(42)
    );
    
    result_union_t result = tagged null;
    result = tagged value '(100);
  end

endmodule

// =============================================================================
// TEST MODULE 3: Union Pattern Matching
// =============================================================================

module test_union_pattern_matching;

  typedef union tagged {
    int int_val;
    real real_val;
    string str_val;
  } value_union_t;

  // Test Case 3.1: Case with pattern matching
  task test_pattern_match(value_union_t val);
    case (val) matches
      tagged int_val .i: $display("Integer: %d", i);
      tagged real_val .r: $display("Real: %g", r);
      tagged str_val .s: $display("String: %s", s);
    endcase
  endtask

  // Test Case 3.2: If-else pattern matching
  task test_if_match(value_union_t val);
    if (val matches tagged int_val .x) begin
      $display("Matched int: %d", x);
    end else if (val matches tagged real_val .r) begin
      $display("Matched real: %g", r);
    end else if (val matches tagged str_val .s) begin
      $display("Matched string: %s", s);
    end
  endtask

  // Test Case 3.3: Pattern matching with constraints
  task test_constrained_match(value_union_t val);
    if (val matches tagged int_val .x && x > 0) begin
      $display("Positive integer: %d", x);
    end
  endtask

  // Test Case 3.4: Nested pattern matching
  typedef union tagged {
    struct {
      int addr;
      int data;
    } mem_op;
    struct {
      string name;
      int value;
    } obj_op;
  } operation_union_t;

  task test_nested_match(operation_union_t op);
    case (op) matches
      tagged mem_op '{addr: .a, data: .d}:
        $display("Memory: addr=%h data=%h", a, d);
      tagged obj_op '{name: .n, value: .v}:
        $display("Object: name=%s value=%d", n, v);
    endcase
  endtask

  initial begin
    value_union_t val1 = tagged int_val '(100);
    value_union_t val2 = tagged real_val '(3.14);
    value_union_t val3 = tagged str_val '("test");
    
    test_pattern_match(val1);
    test_pattern_match(val2);
    test_pattern_match(val3);
  end

endmodule

// =============================================================================
// TEST MODULE 4: Structure Field Constraints
// =============================================================================

module test_struct_field_constraints;

  // Test Case 4.1: Basic struct with constraints
  typedef struct {
    logic [7:0] addr;
    logic [31:0] data;
    logic we, re;
    
    constraint addr_range { addr < 256; }
    constraint ops_exclusive { !(we && re); }
  } bus_transaction_t;

  // Test Case 4.2: Struct with multiple constraints
  typedef struct {
    logic [3:0] priority;
    logic [31:0] payload;
    logic valid;
    
    constraint priority_valid { priority < 16; }
    constraint payload_align { payload[3:0] == 0; }
    constraint valid_payload { valid -> (payload != 0); }
  } priority_packet_t;

  // Test Case 4.3: Struct with implication constraints
  typedef struct {
    logic [15:0] size;
    logic compress;
    logic encrypt;
    logic [31:0] crc;
    
    constraint compress_encrypt { compress -> encrypt; }
    constraint crc_valid { (compress | encrypt) -> (crc != 0); }
  } data_block_t;

  // Test Case 4.4: Struct with array constraints
  typedef struct {
    int values[4];
    int sum;
    
    constraint sum_valid { sum == (values[0] + values[1] + values[2] + values[3]); }
    constraint all_positive { foreach (values[i]) values[i] >= 0; }
  } array_sum_struct_t;

  // Test Case 4.5: Struct with distributive constraints
  typedef struct {
    logic [7:0] red, green, blue;
    
    constraint color_dist {
      red dist { [0:85] := 30, [86:170] := 50, [171:255] := 20 };
      green dist { [0:127] := 40, [128:255] := 60 };
    }
  } color_t;

  initial begin
    bus_transaction_t tx;
    priority_packet_t pkt;
    data_block_t db;
    array_sum_struct_t arr_struct;
    color_t color;
    
    tx.addr = 100;
    tx.data = 32'hDEADBEEF;
    tx.we = 1;
    tx.re = 0;
  end

endmodule

// =============================================================================
// TEST MODULE 5: Constraint Inheritance in Structs
// =============================================================================

module test_struct_constraint_inheritance;

  // Base struct with constraints
  typedef struct {
    logic [7:0] addr;
    logic [31:0] data;
    
    constraint base_addr { addr < 256; }
  } base_transaction_t;

  // Extended struct with additional constraints
  typedef struct {
    base_transaction_t base;
    logic [15:0] tag;
    logic [3:0] priority;
    
    constraint ext_tag { tag > 0; }
    constraint ext_priority { priority < 16; }
  } extended_transaction_t;

  // Randomizable struct with constraints
  class Transaction;
    rand logic [7:0] addr;
    rand logic [31:0] data;
    rand logic [3:0] priority;
    
    constraint addr_range { addr < 256; }
    constraint priority_range { priority < 16; }
    constraint exclusive { addr != 0 -> priority > 0; }
  endclass

  initial begin
    base_transaction_t btx;
    extended_transaction_t etx;
    Transaction txn;
    
    btx.addr = 128;
    btx.data = 32'h12345678;
    
    txn = new();
  end

endmodule

// =============================================================================
// TEST MODULE 6: Type Composition - Basic Composition
// =============================================================================

module test_type_composition_basic;

  // Test Case 6.1: Simple type alias
  typedef int my_int_t;
  typedef real my_real_t;
  typedef string my_string_t;

  // Test Case 6.2: Array type composition
  typedef int int_array_t[7:0];
  typedef my_int_t int_queue_t[$];
  typedef my_int_t int_assoc_t[string];

  // Test Case 6.3: Multi-dimensional array composition
  typedef int int_matrix_t[4:0][3:0];
  typedef logic [31:0] word_array_t[0:15];

  // Test Case 6.4: Composed type using another composed type
  typedef int_array_t typed_array_t;
  typedef typed_array_t nested_array_t[$];

  // Test Case 6.5: Type composition with dimensions
  typedef logic [7:0] byte_t;
  typedef byte_t byte_array_t[0:255];
  typedef byte_array_t memory_t[0:7];

  initial begin
    my_int_t mi = 42;
    int_array_t ia = '{1,2,3,4,5,6,7,8};
    int_queue_t iq;
    int_matrix_t im;
    
    iq.push_back(10);
    iq.push_back(20);
    
    im[0][0] = 1;
    im[4][3] = 255;
  end

endmodule

// =============================================================================
// TEST MODULE 7: Type Composition - Complex Types
// =============================================================================

module test_type_composition_complex;

  // Test Case 7.1: Struct type composition
  typedef struct {
    logic [7:0] addr;
    logic [31:0] data;
  } memory_op_t;

  typedef memory_op_t op_array_t[$];
  typedef op_array_t op_queue_t;

  // Test Case 7.2: Union type composition
  typedef union {
    int int_val;
    real real_val;
  } value_union_t;

  typedef value_union_t union_array_t[int];
  typedef union_array_t union_map_t;

  // Test Case 7.3: Enum type composition
  typedef enum {
    READ, WRITE, SYNC, RESET
  } op_type_t;

  typedef op_type_t op_list_t[$];
  typedef op_list_t op_history_t;

  // Test Case 7.4: Mixed type composition
  typedef struct {
    logic [7:0] addr;
    op_type_t op;
    value_union_t val;
  } complex_op_t;

  typedef complex_op_t complex_queue_t[$];

  initial begin
    op_queue_t oq;
    memory_op_t mop;
    
    mop.addr = 100;
    mop.data = 32'hFFFF0000;
    oq.push_back(mop);
    
    complex_queue_t cq;
    complex_op_t cop;
    cop.addr = 50;
    cop.op = READ;
    cq.push_back(cop);
  end

endmodule

// =============================================================================
// TEST MODULE 8: Type Qualifiers - Const and Static
// =============================================================================

module test_type_qualifiers;

  // Test Case 8.1: Const type composition
  typedef const int const_int_t;
  typedef const logic [31:0] const_word_t;

  // Test Case 8.2: Static type composition
  typedef static int static_int_t;
  typedef static logic [15:0] static_word_t;

  // Test Case 8.3: Const arrays
  typedef const int const_int_array_t[7:0];
  typedef const logic [7:0] const_byte_array_t[$];

  // Test Case 8.4: Combined qualifiers
  typedef const static int const_static_int_t;

  // Test Case 8.5: Qualified struct composition
  typedef const struct {
    logic [7:0] addr;
    logic [31:0] data;
  } const_memory_op_t;

  // Test Case 8.6: Qualified union composition
  typedef static union {
    int int_val;
    real real_val;
  } static_value_union_t;

  initial begin
    const_int_t ci = 42;
    static_int_t si = 100;
    const_int_array_t cia = '{1,2,3,4,5,6,7,8};
  end

endmodule

// =============================================================================
// TEST MODULE 9: Type Aliasing with Typedef
// =============================================================================

module test_type_aliasing;

  // Test Case 9.1: Simple type aliases
  typedef int integer_t;
  typedef logic [7:0] byte_t;
  typedef logic [31:0] word_t;

  // Test Case 9.2: Chained type aliases
  typedef integer_t my_integer_t;
  typedef my_integer_t custom_integer_t;

  // Test Case 9.3: Parametric type aliases (function-based)
  typedef struct {
    int data;
    int timestamp;
  } timestamped_data_t;

  typedef timestamped_data_t timestamped_queue_t[$];

  // Test Case 9.4: Dimension-modified type aliases
  typedef word_t word_array_t[0:15];
  typedef word_array_t word_matrix_t[0:15];

  // Test Case 9.5: Array of arrays with type aliases
  typedef byte_t byte_row_t[0:31];
  typedef byte_row_t byte_table_t[0:31];

  // Test Case 9.6: Type alias using other aliases
  typedef struct {
    integer_t count;
    byte_t status;
    word_t flags;
  } mixed_status_t;

  initial begin
    integer_t ii = 1000;
    byte_t bb = 8'hAA;
    word_t ww = 32'hDEADBEEF;
    
    word_array_t wa;
    wa[0] = 32'h11111111;
    wa[15] = 32'hFFFFFFFF;
    
    byte_table_t bt;
    bt[0][0] = 8'h00;
    bt[31][31] = 8'hFF;
  end

endmodule

// =============================================================================
// TEST MODULE 10: Parametric Types and Type Generation
// =============================================================================

module test_parametric_types
#(
  parameter int WIDTH = 32,
  parameter int DEPTH = 16
);

  // Test Case 10.1: Width-parameterized types
  typedef logic [WIDTH-1:0] word_t;
  typedef word_t memory_line_t[DEPTH-1:0];

  // Test Case 10.2: Depth-parameterized arrays
  typedef int int_array_t[DEPTH-1:0];
  typedef logic [7:0] byte_array_t[DEPTH-1:0];

  // Test Case 10.3: Parametric struct
  typedef struct {
    logic [WIDTH-1:0] data;
    logic [DEPTH-1:0] addr;
  } param_op_t;

  // Test Case 10.4: Parametric type composition
  typedef param_op_t op_queue_t[$];
  typedef op_queue_t op_pipeline_t;

  // Test Case 10.5: Using parameterized types
  function void test_param_types();
    word_t wd;
    memory_line_t mline;
    param_op_t pop;
    
    wd = '1;
    pop.data = '1;
    pop.addr = '0;
  endfunction

endmodule

// =============================================================================
// TEST MODULE 11: Type System Enum Composition
// =============================================================================

module test_enum_composition;

  // Test Case 11.1: Basic enum type composition
  typedef enum {
    IDLE, ACTIVE, ERROR
  } state_t;

  // Test Case 11.2: Enum with explicit values
  typedef enum int {
    READ = 4'h0,
    WRITE = 4'h1,
    FLUSH = 4'h2
  } command_t;

  // Test Case 11.3: Enum array composition
  typedef state_t state_array_t[7:0];
  typedef command_t command_queue_t[$];

  // Test Case 11.4: Struct with enum fields
  typedef struct {
    state_t state;
    command_t cmd;
  } fsm_state_t;

  // Test Case 11.5: Enum in union
  typedef union {
    state_t st;
    command_t cmd;
    int raw_val;
  } op_union_t;

  initial begin
    state_t s = IDLE;
    command_t c = READ;
    state_array_t sa;
    
    sa[0] = IDLE;
    sa[7] = ERROR;
  end

endmodule

// =============================================================================
// TEST MODULE 12: Real Type Composition
// =============================================================================

module test_real_type_composition;

  // Test Case 12.1: Real type aliases
  typedef real floating_point_t;
  typedef shortreal short_float_t;

  // Test Case 12.2: Real arrays
  typedef real real_array_t[0:7];
  typedef floating_point_t float_queue_t[$];

  // Test Case 12.3: Complex number representation
  typedef struct {
    real real_part;
    real imag_part;
  } complex_t;

  // Test Case 12.4: Real in matrix form
  typedef struct {
    real data[3:0][3:0];
  } matrix_4x4_t;

  // Test Case 12.5: Real with precision specifiers
  typedef struct {
    real double_val;
    shortreal float_val;
  } precision_t;

  initial begin
    floating_point_t fp = 3.14159;
    real_array_t ra;
    ra[0] = 1.5;
    ra[7] = 9.9;
  end

endmodule

// =============================================================================
// TEST MODULE 13: Advanced Type Composition Features
// =============================================================================

module test_advanced_type_composition;

  // Test Case 13.1: Recursive type composition (via struct)
  typedef struct {
    int value;
    // Note: Direct recursion not allowed, but can use handles
  } node_t;

  // Test Case 13.2: Type composition with constraints (in structs)
  typedef struct {
    int value;
    constraint positive { value > 0; }
  } positive_int_t;

  // Test Case 13.3: Generic vector type
  typedef logic [7:0] byte_t;
  typedef byte_t byte_vector_t[$];
  typedef byte_vector_t byte_stream_t;

  // Test Case 13.4: Nested struct composition
  typedef struct {
    struct {
      int x;
      int y;
    } coords;
    struct {
      int r;
      int g;
      int b;
    } color;
  } colored_point_t;

  // Test Case 13.5: Union of different sized types
  typedef union {
    logic [7:0] byte_val;
    logic [15:0] word_val;
    logic [31:0] dword_val;
    logic [63:0] qword_val;
  } variable_word_t;

  initial begin
    positive_int_t pi;
    byte_stream_t bs;
    colored_point_t cp;
    
    cp.coords.x = 10;
    cp.coords.y = 20;
    cp.color.r = 255;
    cp.color.g = 128;
    cp.color.b = 0;
  end

endmodule

// =============================================================================
// TEST MODULE 14: Type System Error Cases (Valid Syntax)
// =============================================================================

module test_type_valid_edge_cases;

  // Test Case 14.1: Empty unions (valid SystemVerilog)
  typedef union {
    int a;
  } single_element_union_t;

  // Test Case 14.2: Very large arrays (valid syntax)
  typedef logic [15:0] large_array_t[0:1023];

  // Test Case 14.3: Deeply nested structs
  typedef struct {
    struct {
      struct {
        int value;
      } inner;
    } middle;
  } deeply_nested_t;

  // Test Case 14.4: Type with all dimension types
  typedef struct {
    int fixed_dim[7:0];       // Fixed range
    int dyn_dim[$];           // Dynamic
    int assoc_dim[string];    // Associative
    int queue_dim[$];         // Queue
  } all_dimensions_t;

  // Test Case 14.5: Typedef of typedef of typedef
  typedef int type_level_1;
  typedef type_level_1 type_level_2;
  typedef type_level_2 type_level_3;
  typedef type_level_3 type_level_4;

  initial begin
    single_element_union_t seu;
    large_array_t larray;
    deeply_nested_t dnt;
    all_dimensions_t all_dims;
  end

endmodule

// =============================================================================
// TEST MODULE 15: Type System Integration Test
// =============================================================================

module test_type_system_integration;

  // Integration of all type system features
  
  // Union type with pattern matching
  typedef union tagged {
    int int_val;
    real real_val;
    string str_val;
  } value_t;

  // Struct with constraints and composition
  typedef struct {
    logic [7:0] id;
    value_t value;
    
    constraint id_range { id < 128; }
  } tagged_value_t;

  // Queue of constrained structs
  typedef tagged_value_t tagged_queue_t[$];

  // Parametric composition
  typedef struct {
    tagged_queue_t values;
    int count;
  } value_collection_t;

  // Task combining all features
  task test_integration();
    tagged_value_t tv;
    tagged_queue_t tq;
    value_collection_t vc;
    
    // Create tagged values
    value_t v1 = tagged int_val '(42);
    value_t v2 = tagged real_val '(3.14);
    value_t v3 = tagged str_val '("test");
    
    // Add to queue
    tv.id = 10;
    tv.value = v1;
    tq.push_back(tv);
    
    // Create collection
    vc.values = tq;
    vc.count = tq.size();
  endtask

  initial begin
    test_integration();
  end

endmodule

endmodule : test_type_system_integration
