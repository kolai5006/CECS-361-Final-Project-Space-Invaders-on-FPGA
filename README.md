# CECS-361-Final-Project-Space-Invaders-on-FPGA
Space Invaders on Nexys - A7 100T
- Inputs
-   To start use sw2 on the board
-   To pause use sw1
-   To restart use sw15
-   Buttons on board to move left, right and shoot, use BTNL(Left movement), BTNR(Right movement), BTNU(SHOOT).

How to play:
1. Use sw2 to start the game
2. Destroy all 15 aliens to trigger the win screen
3. Use the reset switch to reset the game.
4. You lose by the aliens reaching you.
5. To pause, use sw1, and it will pause everything on screen.

Other notations:
- The ROM files are generated using the python code, that were referenced from this website here: https://embeddedthoughts.com/ (Yoshi's Nightmare)
- If you are referencing this github, changing the parameter values for either the shot or alien controller is very buggy and often will show out-of-range errors.
- This version of Space Invaders does not include the aliens to shoot back and include additional player lives.
- To understand our project better and what we referenced, please look at the report included in here.
