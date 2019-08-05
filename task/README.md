# Behavioral task for van den Brink et al (2019)

To run the task, run task.m in the folder 'scripts'.

This will prompt an input dialogue where you can set a number of releveant variables:
- participant number
- task (1 = detection, 2 = 2AF discrimination)
- EEG (1 = send triggers, 0 = no triggers)
- subject age
- subject gender
- screen width (in cm)
- and viewing distance (in cm).

Behavioral data are saved per individual block as a tab separated text file, and with all blocks concatinated as a matlab .mat file. 

Output matrix 'data' has 10 columns, with the following variables:
- (1)  trial number within block
- (2)  block number
- (3)  condition (see below)
- (4)  target position (1, left; -1, right)
- (5)  stimulus difficulty
- (6)  RT in seconds
- (7)  response code
- (8)  accuracy (correct or incorrect, 1 or 0)
- (9)  false alarm (yes or no, 1 or 0)
- (10) time on block
- (11) cue number (1 = low, 2 = high)

Condition information: First number (short/long); Second number (valid/invalid); Third number (easy/difficult).

- 10 = catch 
- 100 = short interval, validly cued, easy.
- 101 = short interval, validly cued, difficult.
- 110 = short interval, invalidly cued, easy.
- 111 = short interval, invalidly cued, difficult.
- 200 = long interval, validly cued, easy.
- 201 = long interval, validly cued, difficult.
- 210 = long interval, invalidly cued, easy.
- 211 = long interval, invalidly cued, difficult.


EEG trigger information:

stimulus markers:
 - trial start is indicated by trigger same as condition+30 (see above).
 - 6: cue onset
 - target onset is indicated by trigger condition (see above)

response marker:
 - 7: key press

feedback triggers:
  - 1 = hit trial
  - 2 = miss tiral
  - 3 = false alarm on catch trial
  - 4 = false alarm on non-cath trial
  - 5 = correct reject trial

block markers:
- 60 = start of real task (presented after the practice is complete)