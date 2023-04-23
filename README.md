## TODO

- [x] Add note to run myoudp and start leap stream executables before doing anything else
- [x] Fix gripper
- [x] The In/Out and Up/Down do the same thing but we have no way to rotate the robot, going to use the left hand fist to rotate in one direction.
- [x] The mode filters don't work, we don't really understand why. 
- [ ] Knit and purl aren't being identified remotely correctly, vastly too much jitter even with a stationary human.
- [x] Need to add the cue to do the training data part of the script
- [ ] Update control logic
- [ ] Verify in lab: ModeFilter, movement directions
- [x] Add interaction with actin viewer
- [ ] Knitting circular paths
    - [ ] Debug strange pathing
- [ ] Yarn gripping mechanic?


## 04-23-23
- [ ] Work on physical robot interaction
    - [x] Robot interaction works!
    - [ ] Fix robot manipulations?
    - [ ] Check linkbot with lab6-like DH parameters
        - [ ] If doesn't work, replace with lab6 code
- [ ] Verify filtering
    - [ ] Does the base idea work?
    - [ ] Does the resetting work?
- [ ] Update control logic
    - [ ] Add gripper interaction in initialization phase
    - [ ] Left arm leap control - rotation? in/out movement?
    - [x] Check left/right arm leap classifications.
- [ ] Improve leap classifications
    - [ ] Is mode filtering enough to make this robust?
- [ ] Improve robot pathing
    - [ ] Knit/purl doesn't quite work right for some reason?
    
        Are the link constants right? Is it a timing issue? Is it just the virtual cyton causing problems?