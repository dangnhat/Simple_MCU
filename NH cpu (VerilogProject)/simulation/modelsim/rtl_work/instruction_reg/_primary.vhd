library verilog;
use verilog.vl_types.all;
entity instruction_reg is
    generic(
        bus_width       : integer := 24
    );
    port(
        data_in         : in     vl_logic_vector;
        load_2          : in     vl_logic;
        load_1          : in     vl_logic;
        load_0          : in     vl_logic;
        clock           : in     vl_logic;
        n_reset         : in     vl_logic;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of bus_width : constant is 1;
end instruction_reg;
