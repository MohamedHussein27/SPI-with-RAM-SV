vlib work
vlog RAM.sv 
vlog RAM_IF.sv RAM_SHARED.sv RAM_TRANSACTION.sv RAM_COVERAGE.sv RAM_MONITOR.sv RAM_SCORE.sv RAM_TB.sv RAM_TOP.sv +cover -covercells
vsim -voptargs=+acc work.ram_top -cover 
add wave *
coverage save RAM.ucdb -onexit 
run -all