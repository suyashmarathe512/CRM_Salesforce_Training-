import { LightningElement, track } from 'lwc';
export default class CalculatorInLwc extends LightningElement {
    @track firstNumber;
    @track secondNumber;
    @track resultValue;
    @track errorMessage = '';
    handleNumberOneChange(event) {
        this.firstNumber = Number(event.target.value) || 0;
    }
    handleNumberTwoChange(event) {
        this.secondNumber = Number(event.target.value) || 0;
    }
    addition() {
        this.resultValue = this.firstNumber + this.secondNumber;
    }
    multiplication() { 
        this.resultValue = this.firstNumber * this.secondNumber;
    }
    subtraction() {
        this.resultValue = this.firstNumber - this.secondNumber;
    }
    division() {
        if (this.secondNumber == 0) {
            this.resultValue = 'Cannot divide by zero'; 
            return;
        }
        this.resultValue = this.firstNumber / this.secondNumber;
    }
    errorCallback(error, stack) {
        console.error('Error:', error);
        console.error('Stack trace:', stack);
    }
}
