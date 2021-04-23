# Witness Mechanic Study

----

This project tries to replicate the puzzle mechanics found in the game *The Witness* by Jonathan Blow and Thekla inc. I do not own anything, just wish to understand how it could actually be done and sharing so others can benefit and maybe contribute with some ideas. 

I did this with Godot in GDScript, I'm a beginner in game-making, juste found out how all of this works. Don't hesitate if you have any suggestions or tips and feel free to get inspiration from there.


> I advise checking Debug > Visible Collision Shapes in Godot's interface so   you understand better what is happening (it's not perfect :b)

'Till now, I got the basic movement working : starting at puzzle beginnning, going forward, not crossing the line, going backward, staying in the puzzle... relatively basic stuff, but much more perplexing than I would have thought. I ended using StaticBodies and a KinematicBody2D for the line tip cursor, this way it collides with the other bodies and it restricts movement.

### TODO in the future

- Smooth out movement
- The actual puzzle solving
- Coding puzzle rules, etc
- Snap position to a path or something so it goes straigth, not wobbling around (path may be determine with a script attached to the puzzle)
- Make that the line fills all the space available laterally
- At the beginning, fill the bubble thingy
- When going backwards, movement is a little slower (because of collisions happening). Maybe use test_move() method and remove collision object before colliding with it

If you want to contribute, message me at [yannick.plante16@hotmail.com](yannick.plante16@hotmail.com)




