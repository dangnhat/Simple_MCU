library verilog;
use verilog.vl_types.all;
entity simpleCPU is
    port(
        SW              : in     vl_logic_vector(17 downto 0);
        LEDR            : out    vl_logic_vector(15 downto 0)
    );
end simpleCPU;
