In the first part of the code, the necessary inputs and outputs for the game module are defined.
These include as inputs: the system clock of the FPGA, the UART input, switches for game controls, and a mode selector to switch between UART and switch inputs.
As outputs: VGA synchronization signals, VGA color values, FPGA LEDs, seven-segment display values, and anode controls are used.

Parameters and registers to be used within the module are defined.
The parameters include the maze's cell size, the maze’s height and width, and the position of the target cell.
The registers include individual cell values, player coordinates, game duration values, game completion signal, VGA pixel counters, and clocks operating at suitable frequencies.

In next part, the system clock is slowed down to 25 MHz for VGA display.
Then, the maze generated within the FPGA is upscaled in terms of width and height resolution to appear properly on the screen, and the corresponding values are assigned to the VGA output signals.

VGA signals and maze cells are checked, and the cells, player, and goal location are colored using RGB values.
Depending on whether the cell is occupied or empty, it is colored white or black. The player's position is marked in red, while the target cell is colored green.

Registers are defined to store movement values based on the player's chosen direction, and the previously written UART module is instantiated.
When the clock signal is triggered, the player's input is received depending on the state of the mode-select switch (which determines whether to use UART or switches), and this input is written into the register that stores the movement direction.

The game completion status and the start switch are monitored. If both provide the correct signals, the player is reset to the initial position, the elapsed time is reset to zero, and the game completion signal is set to false. Otherwise, collision detection is performed by comparing the movement direction register with the value of the target cell in that direction. If movement is allowed, the player advances accordingly. Based on the state of the start switch, the elapsed time counter is then activated, and the 100 MHz system clock is converted into seconds. Finally, the player's position is continuously compared to the target cell, and when they match, the game completion signal is set to true.

The value stored in the elapsed time register is written into a display register to be shown on the seven-segment display. The previously written control module for the seven-segment display is then called using this register.
The values indicating whether each of the 300 maze cells is occupied or empty are predefined and assigned accordingly.
A UART module is defined, which takes the system clock and RX signal as inputs and provides an 8-bit UART signal and UART control status as outputs. Although we believe there is no error in the code, we are currently unable to receive W, A, S, D inputs via PuTTY.

A module is defined that takes the system clock and elapsed time as inputs and provides individual LED segment values and anode controls for the seven-segment display as outputs. Within the module, registers are used to store seconds, minutes, digit values based on the system clock, and the current active digit. The elapsed time input is divided by 60 and its modulo is taken to calculate the seconds and minutes. Based on the system clock's timing, the appropriate digit position is selected, and a case block is used to assign the correct anode and digit value. After all digits are calculated, a final case block determines the output value to be sent to the pins of the seven-segment display.
Using the BASYS-3 datasheet, all inputs and outputs defined in the code are correctly mapped to the corresponding pins on the FPGA. These include the system clock, anode values, seven-segment display values, LED pins, switches, micro USB for RX input, and VGA pins including R, G, B, HSync, and VSync.
