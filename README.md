# Witness Mechanic Study

----

This project tries to replicate the puzzle mechanics found in the game *The Witness* by Jonathan Blow and Thekla inc. I do not own anything, just wish to understand how it could actually be done and sharing so others can benefit and maybe contribute with some ideas. 

I did this with Godot in GDScript, I'm a beginner in game-making, juste found out how all of this works. Don't hesitate if you have any suggestions or tips and feel free to get inspiration from there.

'Till now, I got the basic movement working : starting at puzzle beginnning, going forward, not crossing the line, going backward, staying in the puzzle... relatively basic stuff, but much more perplexing than I would have thought.

### TODO in the future

- Smooth out movement
- The actual puzzle solving
- Coding puzzle rules, etc
- <strike>Snap position to a path or something so it goes straigth, not wobbling around (path may be determine with a script attached to the puzzle)</strike>
- Make that the line fills all the space available laterally
- At the beginning, fill the bubble thingy
- Putting a sort of zone around the points in order to smooth movement (you don't need to be exactly on the point to start turning). Might solve a couple of bugs too, if done properly that is....


### Bugs to fix
- Bug after going into the puzzle end (or any end at that) -> it is cause by the proximity of the two points
- Sometimes, the cursor gets separated from the line (it goes forward instead of going backwards...) -> either it's proximity or it's because the point_trace head gets removed and then it's not added again or something.


If you want to contribute, message me at [yannick.plante16@hotmail.com](yannick.plante16@hotmail.com)




