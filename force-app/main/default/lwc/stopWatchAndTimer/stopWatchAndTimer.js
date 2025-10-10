import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StopWatchAndTimer extends LightningElement {
    // Component state properties
    @track elapsedTime = '00:00:00'; // Displayed time in HH:MM:SS format
    @track isRunning = false; // Flag to indicate if counting is active
    @track mode = null; // Current mode: 'stopwatch' or 'timer'
    @track timerDuration = 0; // User-set duration for timer in seconds
    @track remainingTime = 0; // Current time counter in seconds
    intervalId = null; // Reference to the setInterval for timing

    // Computed property for stopwatch button label
    get startStopwatchLabel() {
        if (this.isRunning && this.mode === 'stopwatch') {
            return 'Stop Stopwatch';
        }
        return 'Start Stopwatch';
    }

    // Computed property for timer button label
    get startTimerLabel() {
        if (this.isRunning && this.mode === 'timer') {
            return 'Stop Timer';
        }
        return 'Start Timer';
    }

    // Getter and setter for timer input binding
    get timerInputValue() {
        return this.timerDuration;
    }

    set timerInputValue(value) {
        this.timerDuration = parseInt(value) || 0;
    }

    // Computed property to disable stopwatch button when timer is running
    get isStopwatchDisabled() {
        return this.isRunning && this.mode !== 'stopwatch';
    }

    // Computed property to disable timer button when stopwatch is running
    get isTimerDisabled() {
        return this.isRunning && this.mode !== 'timer';
    }

    // Event handler for timer duration input change
    handleTimerInputChange(event) {
        this.timerDuration = parseInt(event.target.value) || 0;
    }

    // Handler for stopwatch start/stop button
    startStopwatch() {
        if (this.isRunning) {
            this.stopTimer();
        } else {
            this.stopTimer(); // Ensure no other mode is active
            this.mode = 'stopwatch';
            this.isRunning = true;
            this.remainingTime = 0; // Start from zero
            this.startInterval();
        }
    }

    // Handler for timer start/stop button
    startTimer() {
        if (this.timerDuration <= 0) {
            return; // Invalid duration
        }
        if (this.isRunning) {
            this.stopTimer();
        } else {
            this.stopTimer(); // Ensure no other mode is active
            this.mode = 'timer';
            this.remainingTime = this.timerDuration;
            this.isRunning = true;
            this.startInterval();
        }
    }

    // Stop the current interval
    stopTimer() {
        this.isRunning = false;
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }

    // Reset all states to initial
    reset() {
        this.stopTimer();
        this.elapsedTime = '00:00:00';
        this.mode = null;
        this.remainingTime = 0;
    }

    // Initiate the timing interval
    startInterval() {
        this.intervalId = setInterval(() => {
            if (this.mode === 'stopwatch') {
                this.remainingTime += 1; // Increment for stopwatch
                this.formatTime(this.remainingTime);
            } else if (this.mode === 'timer') {
                this.remainingTime -= 1; // Decrement for timer
                this.formatTime(this.remainingTime);
                if (this.remainingTime <= 0) {
                    this.stopTimer();
                    // Dispatch toast event for completion
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Timer Completed',
                            message: 'Your timer has finished!',
                            variant: 'success'
                        })
                    );
                }
            }
        }, 1000); // 1 second interval
    }

    // Format seconds into HH:MM:SS string
    formatTime(totalSeconds) {
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        this.elapsedTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
}
