// A burglar alarm: the siren sounds when the alarm is armed and the door
// or the window is open.
module alarm (
  input  logic armed,        // 1 when the alarm is switched on
  input  logic door_open,    // 1 while the door is open
  input  logic window_open,  // 1 while the window is open
  output logic siren         // 1 to sound the siren
);
  logic opening;  // 1 when the door or the window is open

  assign siren   = armed & opening;  // uses opening before the next line
  assign opening = door_open | window_open;
endmodule
