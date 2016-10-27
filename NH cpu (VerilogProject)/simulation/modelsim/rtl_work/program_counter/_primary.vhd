library verilog;
use verilog.vl_types.all;
entity program_counter is
    generic(
        databus_width   : integer := 16
    );
    port(
        data_in         : in     vl_logic_vector;
        load            : in     vl_logic;
        increase        : in     vl_logic;
        clock           : in     vl_logic;
        n_reset         : in     vl_logic;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of databus_width : constant is 1;
end program_counter;
