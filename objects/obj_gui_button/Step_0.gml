// Calls the current state function that the GUI button is currently executing, but only if the button is
// considered enabled within the program. State updating is ignored otherwise OR if there is no state function
// to execution.
if (BTN_IS_ACTIVE && curState != NO_FUNCTION)
	script_execute(curState);