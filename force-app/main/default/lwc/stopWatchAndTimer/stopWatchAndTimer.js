import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TimeTools extends LightningElement {
    @track formattedStopwatchTime = '00:00:00';
    @track formattedTimerTime = '00:00:00';
    @track stopwatchTime = 0;
    @track stopwatchRunning = false;
    @track laps = [];
    stopwatchInterval;
    stopwatchStartTime;
    @track timerTime = 0; 
    @track timerRunning = false;
    @track isTimerFinished = false;
    @track timerInputs = { hours: '0', minutes: '0', seconds: '0' };
    @track timerStarted = false;
    timerInterval;
    timerInitialTime = 0;

    disconnectedCallback() {
        clearInterval(this.stopwatchInterval);
        clearInterval(this.timerInterval);
    }
    get stopwatchStartLabel() {
        return this.stopwatchRunning ? 'Pause' : 'Start';
    }

    get stopwatchStartIcon() {
        return this.stopwatchRunning ? 'utility:pause' : 'utility:play';
    }

    get isLapButtonDisabled() {
        return !this.stopwatchRunning;
    }

    get stopwatchDisplayClass() {
        return 'time-display';
    }
    handleStopwatchStartPause() {
        this.stopwatchRunning = !this.stopwatchRunning;

        if (this.stopwatchRunning) {
            this.stopwatchStartTime = Date.now() - this.stopwatchTime;
            this.stopwatchInterval = setInterval(() => {
                this.stopwatchTime = Date.now() - this.stopwatchStartTime;
                this.formattedStopwatchTime = this.formatStopwatchTime(this.stopwatchTime);
            }, 1000);
        } else {
            clearInterval(this.stopwatchInterval);
        }
    }

    handleStopwatchReset() {
        this.stopwatchRunning = false;
        clearInterval(this.stopwatchInterval);
        this.stopwatchTime = 0;
        this.formattedStopwatchTime = '00:00:00';
        this.laps = [];
    }

    handleStopwatchLap() {
        if (!this.stopwatchRunning) return;
        this.laps.push({ 
            id: this.laps.length + 1, 
            time: this.formattedStopwatchTime 
        });
    }
    get timerStartLabel() {
        return this.timerRunning ? 'Pause' : 'Start';
    }

    get timerStartIcon() {
        return this.timerRunning ? 'utility:pause' : 'utility:play';
    }

    get isTimerStartDisabled() {
        return this.timerTime <= 0 && !this.timerRunning;
    }

    get timerRunningOrPaused() {
        return this.timerInitialTime > 0;
    }

    get timerDisplayClass() {
        return 'time-display';
    }
    handleTimerInputChange(event) {
        const { id } = event.target.dataset;
        let value = parseInt(event.target.value, 10);

        if (isNaN(value) || value < 0) value = 0;
        if (id === 'minutes' || id === 'seconds') {
            if (value > 59) value = 59;
        }
        this.timerInputs[id] = value.toString();
        this.timerTime = (parseInt(this.timerInputs.hours, 10) * 3600) +
                         (parseInt(this.timerInputs.minutes, 10) * 60) +
                         (parseInt(this.timerInputs.seconds, 10));
        this.timerInitialTime = this.timerTime;
        this.formattedTimerTime = this.formatTimerTime(this.timerTime);
    }
    handleTimerStartPause() {
        this.isTimerFinished = false;
        this.timerRunning = !this.timerRunning;
        this.timerStarted = true;

        if (this.timerRunning) {
            this.timerInterval = setInterval(() => {
                this.timerTime -= 1;
                this.formattedTimerTime = this.formatTimerTime(this.timerTime);
                if (this.timerTime <= 0) {
                    this.finishTimer();
                }
            }, 1000);
        } else {
            clearInterval(this.timerInterval);
        }
    }

    finishTimer() {
        clearInterval(this.timerInterval);
        this.timerRunning = false;
        this.isTimerFinished = true;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Timer Completed',
            message: 'The timer has finished!',
            variant: 'success'
        }));
    }

    handleTimerReset() {
        clearInterval(this.timerInterval);
        this.timerRunning = false;
        this.isTimerFinished = false;
        this.timerStarted = false;
        this.timerTime = 0;
        this.timerInitialTime = 0;
        this.timerInputs = { hours: '0', minutes: '0', seconds: '0' };
        this.formattedTimerTime = '00:00:00';
    }

    formatStopwatchTime(ms) {
        const totalSeconds = Math.floor(ms / 1000);
        const seconds = String(totalSeconds % 60).padStart(2, '0');
        const totalMinutes = Math.floor(totalSeconds / 60);
        const minutes = String(totalMinutes % 60).padStart(2, '0');
        const hours = String(Math.floor(totalMinutes / 60)).padStart(2, '0');
        return `${hours}:${minutes}:${seconds}`;
    }
    formatTimerTime(s) {
        const totalSeconds = Number(s);
        const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, '0');
        const minutes = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, '0');
        const seconds = String(Math.floor(totalSeconds % 60)).padStart(2, '0');
        return `${hours}:${minutes}:${seconds}`;
    }
}