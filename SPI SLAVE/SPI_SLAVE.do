vlib work
vlog SPI_SLAVE.sv 
vlog SPI_SLAVE_IF.sv SPI_SLAVE_SHARED.sv SPI_SLAVE_TRANSACTION.sv SPI_SLAVE_COVERAGE.sv SPI_SLAVE_MONITOR.sv SPI_SLAVE_SCORE.sv SPI_SLAVE_TB.sv SPI_SLAVE_TOP.sv +cover -covercells
vsim -voptargs=+acc work.spi_slave_top -cover 
add wave *
coverage save SPI_SLAVE.ucdb -onexit 
run -all