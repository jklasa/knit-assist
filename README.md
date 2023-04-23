## TODO

- [x] Add note to run myoudp and start leap stream executables before doing anything else
- [x] Fix gripper
- [x] The In/Out and Up/Down do the same thing but we have no way to rotate the robot, going to use the left hand fist to rotate in one direction.
- [x] The mode filters don't work, we don't really understand why. 
- [x] Knit and purl aren't being identified remotely correctly, vastly too much jitter even with a stationary human.
- [x] Need to add the cue to do the training data part of the script
- [ ] Update control logic
- [ ] Verify in lab: ModeFilter, movement directions
- [x] Add interaction with actin viewer
- [x] Knitting circular paths
    - [x] Debug strange pathing
- [ ] Yarn gripping mechanic?


## 04-23-23
- [ ] Work on physical robot interaction
    - [x] Robot interaction works!
    - [x] Fix robot manipulations?
    - [x] Check linkbot with lab6-like DH parameters (Joel, currently)
        - [x] If doesn't work, replace with lab6 code
    - [ ] Fix left/right
    - [ ] At some point in/out wasn't right
    - [ ] Up/down stopped moving at some point
- [ ] Verify filtering **
    - [ ] Does the base idea work?
    - [ ] Does the resetting work?
- [ ] Update control logic
    - [ ] Add gripper interaction in initialization phase **
    - [x] Left arm leap control - rotation? in/out movement? (Amy, currently)
    - [x] Check left/right arm leap classifications.
- [x] Improve leap classifications (Amy, currently)
    - [x] Is mode filtering enough to make this robust?
- [ ] Improve robot pathing
    - [x] Knit/purl doesn't quite work right for some reason
        - This kind of works better - checking with different DH parameters (Joel)
    - [ ] Differentiate knitting vs purling in the paths - how should we do this? **
        - Knit - counterclockwise
        - Purl - clockwise
        - Move center of circle forwards/backwards for each one
            - Knit - back needle
            - Purl - front needle