import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class StopWatchAndTimer extends LightningElement {
    @track elapsedTime = '00:00:00';
    @track isRunning = false;
    @track mode = null;
    @track timerDuration = 0;
    @track remainingTime = 0;
    @track hours = 0;
    @track minutes = 0;
    @track seconds = 0;
    intervalId = null;
    get startStopwatchLabel() {
        if (this.isRunning && this.mode === 'stopwatch') {
            return 'Stop Stopwatch';
        }
        return 'Start Stopwatch';
    }
    get startTimerLabel() {
        if (this.isRunning && this.mode === 'timer') {
            return 'Stop Timer';
        }
        return 'Start Timer';
    }
    get stopwatchIcon() {
        if (this.isRunning && this.mode === 'stopwatch') {
            return 'utility:pause';
        }
        return 'utility:play';
    }
    get timerIcon() {
        if (this.isRunning && this.mode === 'timer') {
            return 'utility:pause';
        }
        return 'utility:play';
    }
    get timerInputValue() {
        return this.timerDuration;
    }
    set timerInputValue(value) {
        this.timerDuration = parseInt(value) || 0;
    }
    get isStopwatchDisabled() {
        return this.isRunning && this.mode !== 'stopwatch';
    }
    get isTimerDisabled() {
        return this.isRunning && this.mode !== 'timer';
    }
    handleHoursChange(event) {
        this.hours = parseInt(event.target.value) || 0;
        this.updateTimerDuration();
    }

    handleMinutesChange(event) {
        this.minutes = parseInt(event.target.value) || 0;
        this.updateTimerDuration();
    }

    handleSecondsChange(event) {
        this.seconds = parseInt(event.target.value) || 0;
        this.updateTimerDuration();
    }

    updateTimerDuration() {
        this.timerDuration = (this.hours * 3600) + (this.minutes * 60) + this.seconds;
    }
    startStopwatch() {
        if (this.isRunning) {
            this.stopTimer();
        } else {
            this.stopTimer();
            this.mode = 'stopwatch';
            this.isRunning = true;
            this.remainingTime = 0;
            this.startInterval();
        }
    }
    startTimer() {
        if (this.timerDuration <= 0) {
            return;
        }
        if (this.isRunning) {
            this.stopTimer();
        } else {
            this.stopTimer();
            this.mode = 'timer';
            this.remainingTime = this.timerDuration;
            this.isRunning = true;
            this.startInterval();
        }
    }
    stopTimer() {
        this.isRunning = false;
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }
    reset() {
        this.stopTimer();
        this.elapsedTime = '00:00:00';
        this.mode = null;
        this.remainingTime = 0;
    }
    startInterval() {
        this.intervalId = setInterval(() => {
            if (this.mode === 'stopwatch') {
                this.remainingTime += 1;
                this.formatTime(this.remainingTime);
            } else if (this.mode === 'timer') {
                this.remainingTime -= 1;
                this.formatTime(this.remainingTime);
                if (this.remainingTime <= 0) {
                    this.stopTimer();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Timer Completed',
                            message: 'Your timer has finished!',
                            variant: 'success'
                        })
                    );
                }
            }
        }, 1000);
    }
    formatTime(totalSeconds) {
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        this.elapsedTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
}
