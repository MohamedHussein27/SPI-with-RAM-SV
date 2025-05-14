vlib work
vlog SPI_WRAPPER.sv 
vlog SPI_WRAPPER_IF.sv SPI_WRAPPER_SHARED.sv SPI_WRAPPER_TRANSACTION.sv SPI_WRAPPER_COVERAGE.sv SPI_WRAPPER_MONITOR.sv SPI_WRAPPER_SCORE.sv SPI_WRAPPER_TB.sv SPI_WRAPPER_TOP.sv SPI_SLAVE.v RAM.v +cover -covercells
vsim -voptargs=+acc work.spi_wrapper_top -cover 
add wave *
coverage save SPI_WRAPPER.ucdb -onexit 
run -all