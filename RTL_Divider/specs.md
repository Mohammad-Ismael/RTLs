Specifications and behavior of the RTL for the `Divider` module, including normal operations and corner cases:

| **Aspect**              | **Description**                                                                                       |
|-------------------------|-------------------------------------------------------------------------------------------------------|
| **Module Name**         | `Divider`                                                                                            |
| **Inputs**              | - `clk`: Clock signal <br> - `reset`: Reset signal (active high) <br> - `start`: Start signal to begin division operation <br> - `Dividend` [31:0]: Dividend input for division <br> - `Divisor` [31:0]: Divisor input for division |
| **Outputs**             | - `Quotient` [31:0]: Result of the division <br> - `Remainder` [31:0]: Remainder from the division <br> - `RDY`: Ready signal indicating completion of the division <br> - `error`: Error flag (set when Divisor is 0) |
| **Division Methodology**| Implements a bitwise long division algorithm where the quotient is computed by shifting bits and comparing partial remainders with the divisor |
| **Operation Trigger**   | The division process begins when the `start` signal is asserted, provided `reset` is not active     |
| **Ready Signal (RDY)**  | - `RDY` is 0 when the division is active <br> - `RDY` becomes 1 once the division is complete, indicating the results (Quotient, Remainder) are valid |
| **Error Condition**     | The `error` signal is high when `Divisor` is 0, preventing the division from starting               |


**Normal Operation** : 
1. **Start Condition** : 
  - When `start` is asserted, the division process begins (if not already active).
 
  - The division takes 32 clock cycles to complete (31 cycles are counted down using `cycle`).
 
  - Each clock cycle, the partial remainder (`work`) and quotient (`result`) are updated.
 
2. **Division Algorithm** : 
  - On each clock cycle, the module shifts `work` and `result` left by 1 bit.
 
  - If the difference `sub[32]` is 0 (meaning the current remainder is larger than or equal to the divisor), the remainder is updated, and the quotient is incremented by setting the least significant bit.
 
  - If `sub[32]` is 1, no subtraction occurs, and the quotient’s least significant bit remains 0.
 
3. **End Condition** : 
1 - Once the division is complete (i.e., after 32 cycles), the `active` signal goes low, and the `RDY` signal goes high, indicating the Quotient and Remainder are ready.

| **Corner Case**|**Behavior**|
|-----|----------------------------------------------------|
| **Divisor = 0**                       | - The `error` signal is asserted (set to 1) when `Divisor == 0`. <br> - Division does not proceed, and the module stays idle. |
| **Dividend = 0**                      | - The division will complete normally, with the `Quotient = 0` and `Remainder = 0`.                                   |
| **Divisor = 1**                       | - The `Quotient` will be equal to the `Dividend`, and the `Remainder` will be 0.                                    |
| **Large Dividend and Small Divisor**  | - The algorithm will work as expected, providing a large `Quotient` and a small `Remainder`.                        |
| **Small Dividend and Large Divisor**  | - The `Quotient` will be 0, and the `Remainder` will be equal to the `Dividend`.                                    |

### Timing Behavior 
 
- **Reset** : Asserting `reset` sets all internal states (`active`, `cycle`, `result`, `denom`, `work`) to their initial values. Division will only start after `reset` is deasserted.
 
- **Latency** : The division takes 32 clock cycles once the `start` signal is asserted, and the results are ready after the `RDY` signal is asserted.


# Sequences To build

`Reset Sequence`: Assert the reset signal and check that all internal registers (active, c_counter, result, denom, work) are set to zero.
`Basic Division`: Apply a valid Dividend and Divisor, assert start, and verify that Quotient and Remainder are correct after the division completes (RDY goes high).
`Division by Zero`: Apply a valid Dividend and set Divisor to zero, assert start, and verify that the error signal is asserted.
`Multiple Divisions`: Perform multiple division operations back-to-back without asserting reset in between, ensuring each result is correct.
`Edge Case Dividends`: Test with edge case values for Dividend such as 0xFFFFFFFF, 0x00000000, 0x80000000, and verify the results.
`Edge Case Divisors`: Test with edge case values for Divisor such as 0xFFFFFFFF, 0x00000001, 0x80000000, and verify the results.
`Randomized Testing`: Apply random values for Dividend and Divisor, assert start, and verify the correctness of Quotient and Remainder.
`Stress Test`: Apply a continuous stream of random Dividend and Divisor values with minimal delay between operations to test the robustness of the module.