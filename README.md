# SPI Slave with Single-Port RAM Verification

This project verifies an **SPI Slave with a Single-Port RAM** using a SystemVerilog testbench.  
The testbench is built using a modular layered structure with **transactions, driver, monitor, scoreboard, coverage, and assertions** to ensure correctness and completeness.

## General Specifications
- **Write Address State:**  
  First received bit on `MOSI` is `0`, followed by `2'b00`.
- **Write Data State:**  
  First received bit on `MOSI` is `0`, followed by `2'b01`.
- **Read Address State:**  
  First received bit on `MOSI` is `1`, followed by `2'b10`.
- **Read Data State:**  
  First received bit on `MOSI` is `1`, followed by `2'b11`.

For more details about the SPI protocol behavior and RTL design, please check the **Design Repository: (_SPI Slave with Single-Port RAM_)[https://github.com/MohamedHussein27/SPI_Slave_With_Single_Port_Memory]**.

---

## Verification Environment Overview

![Test bench](https://github.com/MohamedHussein27/SPI-with-RAM-SV/blob/main/Documentation/Testbench.png)

- **Transaction (Sequence Item):**  
  Represents abstract stimulus such as SPI read/write commands, data payloads, and memory addresses.

- **Driver:**  
  Converts transactions into pin-level SPI protocol activity (`MOSI`, `SCLK`, `CS`).  
  Sends inputs to the **DUT (SPI + RAM Wrapper)**.

- **DUT (SPI + RAM Wrapper):**  
  The SPI Slave interprets commands and interacts with the single-port RAM for read/write operations.

- **Monitor:**  
  Observes outputs (`MISO`, status, RAM responses).  
  Reconstructs transactions from DUT activity and forwards them to scoreboard and coverage.

- **Scoreboard:**  
  Acts as a checker by comparing DUT outputs against expected reference results.  
  Flags mismatches as functional errors.

- **Assertions:**  
  Ensure SPI protocol correctness (timing, chip select behavior, state transitions).  
  Catch illegal scenarios early.

- **Coverage:**  
  Captures exercised scenarios (e.g., read/write, boundary addresses, burst operations).  
  Ensures completeness of verification.

- **Top/Test:**  
  Instantiates all components, binds the interface, and runs sequences.  
  Can generate both directed and constrained-random testcases.

---

## Verification Flow

1. **Test Initialization:**  
   Environment (driver, monitor, scoreboard, coverage) is created and connected to the DUT interface.

2. **Transaction Generation:**  
   Directed or constrained-random transactions are generated, specifying operation type, data, and address.

3. **Driver Action:**  
   Transactions are converted into SPI signal activity and driven into the DUT.

4. **DUT Execution:**  
   - **Write:** Data is stored into RAM.  
   - **Read:** Data is fetched from RAM and sent back over `MISO`.

5. **Monitor Collection:**  
   DUT outputs are observed and reconstructed into higher-level transactions.

6. **Scoreboard Check:**  
   Observed results are compared against expected behavior.  
   Any mismatches are flagged as errors.

7. **Assertions Check:**  
   Continuous monitoring of SPI protocol timing and behavior.

8. **Coverage Update:**  
   Functional coverage is updated for each exercised scenario.

9. **Test Completion:**  
   Scoreboard confirms correctness, and coverage reports indicate completeness.

---

## Notes

- This testbench creates a **self-checking, reusable, and coverage-driven verification environment**.  
- For a more detailed and deeper verification explanation, please check the **[Documentation](https://github.com/MohamedHussein27/SPI-with-RAM-SV/blob/main/Documentation/SPI%20Using%20SV.pdf)** folder.


## Contact Me!
- [Email](mailto:Mohamed_Hussein2100924@outlook.com)
- [WhatsApp](https://wa.me/+2001097685797)
- [LinkedIn](https://www.linkedin.com/in/mohamed-hussein-274337231)