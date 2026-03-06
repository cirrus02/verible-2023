// Interface & Modport Features Test Suite
// IEEE 1800-2023 Compliance Test Cases
// Phase 4: Type System, Packages & Interfaces
//
// Covers:
// - Interface declarations (Clause 25.1)
// - Modport specifications (Clause 25.3)
// - Clocking blocks in interfaces (Clause 14.3)
// - Interface features and examples

// =============================================================================
// TEST INTERFACE 1: Simple Interface with Basic Modports
// =============================================================================

interface simple_handshake_if;
  logic valid;
  logic ready;
  
  modport source (
    output valid,
    input ready
  );
  
  modport sink (
    input valid,
    output ready
  );
endinterface : simple_handshake_if

// =============================================================================
// TEST INTERFACE 2: Interface with Data Payload
// =============================================================================

interface data_channel_if;
  logic [7:0] data;
  logic valid;
  logic ready;
  logic last;
  
  modport master (
    output data, valid, last,
    input ready
  );
  
  modport slave (
    input data, valid, last,
    output ready
  );
endinterface : data_channel_if

// =============================================================================
// TEST INTERFACE 3: Interface with Multiple Modports
// =============================================================================

interface multi_modport_if;
  logic [31:0] addr;
  logic [31:0] data;
  logic [3:0] we;
  logic [3:0] re;
  logic ack;
  
  // Master modport
  modport master (
    output addr, data, we, re,
    input ack
  );
  
  // Slave modport
  modport slave (
    input addr, data, we, re,
    output ack
  );
  
  // Monitor modport (read-only)
  modport monitor (
    input addr, data, we, re, ack
  );
endinterface : multi_modport_if

// =============================================================================
// TEST INTERFACE 4: Interface with Clocking Block
// =============================================================================

interface clocked_handshake_if (
  input logic clk,
  input logic rst_n
);
  logic valid;
  logic ready;
  
  // Default clocking block
  default clocking cb @(posedge clk);
    output valid;
    input ready;
    default input #1 output #1;
  endclocking
  
  // Reset signal (asynchronous)
  async reset_n = rst_n;
  
  modport source (
    clocking cb,
    async reset_n
  );
  
  modport sink (
    clocking cb,
    async reset_n
  );
endinterface : clocked_handshake_if

// =============================================================================
// TEST INTERFACE 5: Interface with Named Clocking Blocks
// =============================================================================

interface multi_clock_if (
  input logic clk1,
  input logic clk2,
  input logic clk_async
);
  logic [7:0] data_sync;
  logic [7:0] data_async;
  logic valid;
  
  // First clock domain
  clocking cb1 @(posedge clk1);
    output data_sync, valid;
    default input #1 output #1;
  endclocking
  
  // Second clock domain
  clocking cb2 @(posedge clk2);
    input data_sync;
    default input #1 output #1;
  endclocking
  
  // Asynchronous signals
  modport sync_source (
    clocking cb1
  );
  
  modport sync_sink (
    clocking cb2
  );
  
  modport async_access (
    input data_async
  );
endinterface : multi_clock_if

// =============================================================================
// TEST INTERFACE 6: Memory Interface
// =============================================================================

interface memory_if #(
  parameter int ADDR_WIDTH = 10,
  parameter int DATA_WIDTH = 32
);
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] data_wr;
  logic [DATA_WIDTH-1:0] data_rd;
  logic we;
  logic re;
  logic valid;
  
  modport master (
    output addr, data_wr, we, re,
    input data_rd, valid
  );
  
  modport slave (
    input addr, data_wr, we, re,
    output data_rd, valid
  );
endinterface : memory_if

// =============================================================================
// TEST INTERFACE 7: AXI-like Interface
// =============================================================================

interface axi_like_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 64
);
  // Write address channel
  logic [ADDR_WIDTH-1:0] awaddr;
  logic awvalid;
  logic awready;
  
  // Write data channel
  logic [DATA_WIDTH-1:0] wdata;
  logic wvalid;
  logic wready;
  
  // Write response channel
  logic bvalid;
  logic bready;
  
  // Read address channel
  logic [ADDR_WIDTH-1:0] araddr;
  logic arvalid;
  logic arready;
  
  // Read data channel
  logic [DATA_WIDTH-1:0] rdata;
  logic rvalid;
  logic rready;
  
  modport master (
    output awaddr, awvalid, wdata, wvalid, bready, araddr, arvalid, rready,
    input awready, wready, bvalid, arready, rdata, rvalid
  );
  
  modport slave (
    input awaddr, awvalid, wdata, wvalid, bready, araddr, arvalid, rready,
    output awready, wready, bvalid, arready, rdata, rvalid
  );
endinterface : axi_like_if

// =============================================================================
// TEST INTERFACE 8: Interface with Virtual Modports
// =============================================================================

interface priority_if;
  logic [7:0] data;
  logic [3:0] priority;
  logic valid;
  logic ready;
  
  modport high_priority (
    output priority,
    input data, valid, ready
  );
  
  modport low_priority (
    input priority,
    output data, valid, ready
  );
  
  modport bidirectional (
    inout data, priority, valid, ready
  );
endinterface : priority_if

// =============================================================================
// TEST MODULE 1: Simple Interface Usage
// =============================================================================

module source_module_simple (simple_handshake_if.source if);
  
  initial begin
    for (int i = 0; i < 10; i++) begin
      if.valid <= 1;
      #10;
      wait (if.ready);
      if.valid <= 0;
      #10;
    end
  end
  
endmodule : source_module_simple

module sink_module_simple (simple_handshake_if.sink if);
  
  always @(if.valid) begin
    if (if.valid) begin
      #5;
      if.ready <= 1;
      #5;
      if.ready <= 0;
    end
  end
  
endmodule : sink_module_simple

// =============================================================================
// TEST MODULE 2: Data Channel Interface Usage
// =============================================================================

module data_producer (data_channel_if.master if);
  
  initial begin
    for (int i = 0; i < 256; i++) begin
      if.data <= 8'(i);
      if.valid <= 1;
      if.last <= (i == 255) ? 1 : 0;
      @(if.ready);
    end
    if.valid <= 0;
  end
  
endmodule : data_producer

module data_consumer (data_channel_if.slave if);
  
  always @(if.valid) begin
    if (if.valid) begin
      #3;
      if.ready <= 1;
      #1;
      if.ready <= 0;
    end
  end
  
endmodule : data_consumer

// =============================================================================
// TEST MODULE 3: Multiple Modport Access
// =============================================================================

module multi_modport_master (multi_modport_if.master if);
  
  initial begin
    for (int i = 0; i < 100; i++) begin
      if.addr <= 32'(i);
      if.data <= 32'(i * 2);
      if.we <= 4'hF;
      if.re <= 4'h0;
      #10;
    end
  end
  
endmodule : multi_modport_master

module multi_modport_slave (multi_modport_if.slave if);
  
  always @(if.we) begin
    #2;
    if.ack <= 1;
    #2;
    if.ack <= 0;
  end
  
endmodule : multi_modport_slave

module multi_modport_monitor (multi_modport_if.monitor if);
  
  always @(if.we or if.re) begin
    if (if.we != 0) begin
      $display("Write to addr: 0x%08h, data: 0x%08h", if.addr, if.data);
    end
    if (if.re != 0) begin
      $display("Read from addr: 0x%08h", if.addr);
    end
  end
  
endmodule : multi_modport_monitor

// =============================================================================
// TEST MODULE 4: Clocked Interface Usage
// =============================================================================

module clocked_source (clocked_handshake_if.source if);
  
  initial begin
    wait (if.reset_n);
    repeat (20) begin
      @(if.cb);
      if.cb.valid <= $random % 2;
    end
  end
  
endmodule : clocked_source

module clocked_sink (clocked_handshake_if.sink if);
  
  initial begin
    wait (if.reset_n);
    repeat (20) begin
      @(if.cb);
      if.cb.ready <= $random % 2;
    end
  end
  
endmodule : clocked_sink

// =============================================================================
// TEST MODULE 5: Memory Interface Implementation
// =============================================================================

module memory_master (memory_if mem_if);
  
  parameter int ADDR_WIDTH = mem_if.ADDR_WIDTH;
  parameter int DATA_WIDTH = mem_if.DATA_WIDTH;
  
  initial begin
    for (int addr = 0; addr < 100; addr++) begin
      mem_if.addr <= addr;
      mem_if.data_wr <= 32'(addr * 10);
      mem_if.we <= 1;
      mem_if.re <= 0;
      #10;
    end
    
    for (int addr = 0; addr < 100; addr++) begin
      mem_if.addr <= addr;
      mem_if.we <= 0;
      mem_if.re <= 1;
      #10;
      wait (mem_if.valid);
    end
  end
  
endmodule : memory_master

module memory_slave (memory_if mem_if);
  
  logic [mem_if.DATA_WIDTH-1:0] mem[2**mem_if.ADDR_WIDTH-1:0];
  
  always @(mem_if.we or mem_if.re) begin
    if (mem_if.we) begin
      mem[mem_if.addr] <= mem_if.data_wr;
      #2;
    end
    if (mem_if.re) begin
      mem_if.data_rd <= mem[mem_if.addr];
      mem_if.valid <= 1;
      #2;
      mem_if.valid <= 0;
    end
  end
  
endmodule : memory_slave

// =============================================================================
// TEST MODULE 6: AXI-like Interface Implementation
// =============================================================================

module axi_master (axi_like_if axi_if);
  
  initial begin
    // Write transaction
    axi_if.awaddr <= 32'h1000;
    axi_if.awvalid <= 1;
    #10;
    wait (axi_if.awready);
    axi_if.awvalid <= 0;
    
    axi_if.wdata <= 64'hDEADBEEFCAFEBABE;
    axi_if.wvalid <= 1;
    #10;
    wait (axi_if.wready);
    axi_if.wvalid <= 0;
    
    #10;
    wait (axi_if.bvalid);
    axi_if.bready <= 1;
    #10;
    axi_if.bready <= 0;
  end
  
endmodule : axi_master

module axi_slave (axi_like_if axi_if);
  
  logic [63:0] mem[0:255];
  
  always @(axi_if.awvalid) begin
    if (axi_if.awvalid) begin
      #1;
      axi_if.awready <= 1;
      #1;
      axi_if.awready <= 0;
    end
  end
  
  always @(axi_if.wvalid) begin
    if (axi_if.wvalid) begin
      mem[axi_if.awaddr[7:0]] <= axi_if.wdata;
      #2;
      axi_if.wready <= 1;
      #1;
      axi_if.wready <= 0;
    end
  end
  
endmodule : axi_slave

// =============================================================================
// TEST MODULE 7: Priority Interface
// =============================================================================

module priority_high (priority_if.high_priority if);
  
  initial begin
    if.priority <= 4'hF;
    for (int i = 0; i < 10; i++) begin
      wait (!if.ready);
      #5;
      wait (if.valid);
      #3;
    end
  end
  
endmodule : priority_high

module priority_low (priority_if.low_priority if);
  
  initial begin
    if.priority <= 4'h0;
    for (int i = 0; i < 10; i++) begin
      if.data <= 8'(i);
      if.valid <= 1;
      #10;
      if.valid <= 0;
      #10;
    end
  end
  
endmodule : priority_low

// =============================================================================
// TEST MODULE 8: Interface with Generate
// =============================================================================

module interface_with_generate (data_channel_if.master if);
  
  generate
    for (genvar i = 0; i < 4; i++) begin : data_gen
      initial begin
        #(i * 10);
        for (int j = 0; j < 16; j++) begin
          if.data <= 8'(i * 16 + j);
          if.valid <= 1;
          if.last <= (j == 15) ? 1 : 0;
          @(if.ready);
        end
      end
    end
  endgenerate
  
endmodule : interface_with_generate

// =============================================================================
// TEST MODULE 9: Interface in Parameter
// =============================================================================

module param_interface_user #(
  parameter int WIDTH = 8,
  parameter int DEPTH = 16
) (
  memory_if mem_if
);
  
  initial begin
    for (int i = 0; i < DEPTH; i++) begin
      mem_if.addr <= i;
      mem_if.data_wr <= 32'(i);
      mem_if.we <= 1;
      #5;
    end
  end
  
endmodule : param_interface_user

// =============================================================================
// TEST MODULE 10: Hierarchical Interface Usage
// =============================================================================

module hierarchical_top;
  
  // Create interfaces
  simple_handshake_if hs_if();
  data_channel_if dc_if();
  memory_if #(.ADDR_WIDTH(10), .DATA_WIDTH(32)) mem_if();
  
  // Instantiate modules
  source_module_simple src (.if(hs_if.source));
  sink_module_simple snk (.if(hs_if.sink));
  
  data_producer dp (.if(dc_if.master));
  data_consumer dc (.if(dc_if.slave));
  
  memory_master mm (.mem_if(mem_if));
  memory_slave ms (.mem_if(mem_if));
  
endmodule : hierarchical_top

// =============================================================================
// TEST MODULE 11: Interface in Task Parameter
// =============================================================================

module interface_in_task;
  
  task transfer_data(data_channel_if.master if, logic [7:0] data[], int count);
    foreach (data[i]) begin
      if.data <= data[i];
      if.valid <= 1;
      if.last <= (i == (count - 1)) ? 1 : 0;
      @(if.ready);
    end
    if.valid <= 0;
  endtask
  
  initial begin
    data_channel_if dc_if();
    logic [7:0] test_data[256];
    
    for (int i = 0; i < 256; i++) begin
      test_data[i] = 8'(i);
    end
    
    transfer_data(dc_if.master, test_data, 256);
  end
  
endmodule : interface_in_task

// =============================================================================
// TEST MODULE 12: Interface Array Usage
// =============================================================================

module interface_array_test;
  
  data_channel_if if_array[4]();
  
  generate
    for (genvar i = 0; i < 4; i++) begin : if_gen
      data_producer #() dp_i (.if(if_array[i].master));
      data_consumer #() dc_i (.if(if_array[i].slave));
    end
  endgenerate
  
endmodule : interface_array_test

// =============================================================================
// TEST MODULE 13: Interface with Modport Selection
// =============================================================================

module modport_selector (
  input int modport_type,
  multi_modport_if.master mif_m,
  multi_modport_if.slave mif_s
);
  
  task select_and_use();
    case (modport_type)
      0: begin  // Master access
        mif_m.addr <= 32'h1000;
        mif_m.we <= 4'hF;
      end
      1: begin  // Slave access
        mif_s.ack <= 1;
      end
      default: begin
        $display("Invalid modport type");
      end
    endcase
  endtask
  
  initial begin
    select_and_use();
  end
  
endmodule : modport_selector

// =============================================================================
// TEST MODULE 14: Clocking Block Features
// =============================================================================

module clocking_features (clocked_handshake_if.source if);
  
  initial begin
    wait (if.reset_n);
    
    // Use clocking block for synchronization
    repeat (10) begin
      @(if.cb);
      if.cb.valid <= 1;
      @(if.cb);
      if.cb.valid <= 0;
      @(if.cb);
    end
  end
  
endmodule : clocking_features

// =============================================================================
// TEST MODULE 15: Advanced Interface Patterns
// =============================================================================

module advanced_interface_patterns;
  
  interface advanced_if;
    logic [31:0] data;
    logic valid, ready;
    
    property data_stable_when_valid;
      @(posedge valid) $stable(data);
    endproperty
    
    modport producer (
      output data, valid,
      input ready
    );
    
    modport consumer (
      input data, valid,
      output ready
    );
  endinterface : advanced_if
  
  module producer (advanced_if.producer if);
    initial begin
      for (int i = 0; i < 100; i++) begin
        if.data <= 32'(i);
        if.valid <= 1;
        @(if.ready);
        if.valid <= 0;
        #5;
      end
    end
  endmodule : producer
  
  module consumer (advanced_if.consumer if);
    always @(if.valid) begin
      if (if.valid) begin
        #2;
        if.ready <= 1;
        #2;
        if.ready <= 0;
      end
    end
  endmodule : consumer
  
  advanced_if adv_if();
  producer prod_m (.if(adv_if.producer));
  consumer cons_m (.if(adv_if.consumer));
  
endmodule : advanced_interface_patterns

// =============================================================================
// TEST MODULE 16: Interface with Assertions
// =============================================================================

module interface_with_assertions;
  
  interface asserted_if;
    logic [31:0] data;
    logic valid, ready;
    
    // Assertions for interface protocol
    assert property (@(posedge valid) !valid until ready)
      else $error("Valid must remain high until ready");
    
    modport source (
      output data, valid,
      input ready
    );
    
    modport sink (
      input data, valid,
      output ready
    );
  endinterface : asserted_if
  
  initial begin
    $display("Interface with assertions created");
  end
  
endmodule : interface_with_assertions

// =============================================================================
// TEST MODULE 17: Dynamic Interface Usage
// =============================================================================

module dynamic_interface_usage;
  
  class InterfaceHandler;
    virtual memory_if mem_if;
    
    function new(virtual memory_if if_h);
      mem_if = if_h;
    endfunction
    
    task write_memory(int addr, logic [31:0] data);
      mem_if.addr <= addr;
      mem_if.data_wr <= data;
      mem_if.we <= 1;
      #10;
      mem_if.we <= 0;
    endtask
    
    task read_memory(int addr);
      mem_if.addr <= addr;
      mem_if.re <= 1;
      #10;
      mem_if.re <= 0;
    endtask
  endclass
  
  memory_if mem_if();
  InterfaceHandler handler;
  
  initial begin
    handler = new(mem_if);
    handler.write_memory(0, 32'hDEADBEEF);
    handler.read_memory(0);
  end
  
endmodule : dynamic_interface_usage

// =============================================================================
// TEST MODULE 18: Interface Parameterization
// =============================================================================

module param_test #(
  parameter int ADDR_WIDTH = 10,
  parameter int DATA_WIDTH = 32
);
  
  memory_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) mem_if();
  
  initial begin
    $display("Memory interface created with ADDR_WIDTH=%0d, DATA_WIDTH=%0d",
             ADDR_WIDTH, DATA_WIDTH);
  end
  
endmodule : param_test

// =============================================================================
// TEST MODULE 19: Nested Interface Hierarchies
// =============================================================================

module nested_hierarchy;
  
  module layer1;
    simple_handshake_if hs_if();
    
    module layer2;
      // Use parent interface
      assign hs_if.valid = 1'b1;
      assign hs_if.ready = 1'b1;
    endmodule : layer2
    
    layer2 l2_inst();
  endmodule : layer1
  
  layer1 l1_inst();
  
endmodule : nested_hierarchy

// =============================================================================
// TEST MODULE 20: Complete Interface Example
// =============================================================================

module complete_interface_example;
  
  // Interface with all features
  interface complete_if #(
    parameter int DATA_WIDTH = 32
  ) (
    input logic clk,
    input logic rst_n
  );
    logic [DATA_WIDTH-1:0] data;
    logic valid, ready;
    logic [3:0] priority;
    
    // Clocking block
    clocking cb @(posedge clk);
      output data, valid, priority;
      input ready;
      default input #1 output #1;
    endclocking
    
    // Async reset
    async reset_n = rst_n;
    
    // Modports
    modport source (
      clocking cb,
      async reset_n
    );
    
    modport sink (
      clocking cb,
      async reset_n
    );
  endinterface : complete_if
  
  // Test instantiation
  complete_if #(.DATA_WIDTH(64)) comp_if (
    .clk(1'b0),
    .rst_n(1'b1)
  );
  
  initial begin
    $display("Complete interface with all features created");
  end
  
endmodule : complete_interface_example

endmodule : test_import_scope
