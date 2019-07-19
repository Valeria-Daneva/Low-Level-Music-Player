# Low-Level-Music-Player
A music player written in ARM Assembly code meant to run on an ARM-based UoM architecture. This was originally written as part of a mandatory project exercise for the COMP22712 course unit. It is meant to be run on a microcontroller connected to a keyboard with a buzzer module.

This programme has two modes - playing a note specified by the user or playing a set tune. The way to switch between either of them is pressing the star key. The user cannot switch between modes whilst the operation specified is still running.

When in note playing mode, the user should enter three variables, using the hash key as a return signifier, in this specific order. The first is the pitch, which goes from 1 to 12; then octave, which goes from 1 to 8; and length, which has no limit.  The length is specified in tens of seconds. The user will receive an error message if they go out of bounds for either of the first two variables. After the length has been specified, the note will play out, after which the screen will be cleared, allowing the user to specify a new note.

When in tune playing mode, the song will just play out and stop when it's finished, allowing the user to switch back to note playing mode.

The schematic shown below is of the hardware I was required to add to one or more ports in order for the buzzer to be programmable.

![Hardware Schematic](https://user-images.githubusercontent.com/41366614/61531556-0ff60400-aa1f-11e9-8fc9-da43423d2f85.jpg)
