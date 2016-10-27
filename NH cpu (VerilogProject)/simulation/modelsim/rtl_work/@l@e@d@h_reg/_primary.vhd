library verilog;
use verilog.vl_types.all;
entity LEDH_reg is
    generic(
        bus_width       : integer := 8
    );
    port(
        data_in         : in     vl_logic_vector;
        load            : in     vl_logic;
        clock           : in     vl_logic;
        n_reset         : in     vl_logic;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of bus_width : constant is 1;
end LEDH_reg;
