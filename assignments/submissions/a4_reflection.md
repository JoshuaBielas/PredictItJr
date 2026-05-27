The solution of storing state and setting state in different screens didn't work because they were separate states.
Modifying one did not have any effect on the other because they are separate. It needs to be stored somewhere where both 
screens can have access to the same variable. This allows modification in one screen to be visible in another screen.