// Update the current state at the very end of the program's update events to ensure a state change doesn't
// occur within the middle fo a frame, which could potentially cause issues.
if (curState != nextState){
	lastState = curState;
	curState = nextState;
}

// Calculate delta time such that 1 unit equals out to around 1/60th of a second.
deltaTime = delta_time / 1000000 * 60;

keyboard_string = "";