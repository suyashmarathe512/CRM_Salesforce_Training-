import { LightningElement, track } from 'lwc';
export default class CalculatorInLwc extends LightningElement {
    @track firstNumber;
    @track secondNumber;
    @track resultValue;
    @track errorMessage = '';
    // Handle change for first number input
    handleNumberOneChange(event) {
        this.firstNumber = Number(event.target.value) || 0;
    }
    // Handle change for second number input
    handleNumberTwoChange(event) {
        this.secondNumber = Number(event.target.value) || 0;
    }
    // Perform addition
    addition() {
        this.resultValue = this.firstNumber + this.secondNumber;
    }
    // Perform multiplication
    multiplication() { 
        this.resultValue = this.firstNumber * this.secondNumber;
    }
    // Perform subtraction
    subtraction() {
        this.resultValue = this.firstNumber - this.secondNumber;
    }
    // Perform division
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
