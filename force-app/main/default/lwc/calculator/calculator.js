import { LightningElement, track } from 'lwc';
export default class Calculator extends LightningElement {
  @track result = '';
  handleClick(event) {
    const value = event.target.value;
    this.result = `${this.result}${value}`;
  }
  calculateResult() {
    try {
      const expr = this.result.replace(/\b\d+(\.\d+)?\b/g, (n) => String(+n));
      const out = eval(expr);
      this.result = Number.isFinite(out) ? String(out) : 'Error';
    } catch (e) {
      this.result = 'Error';
    }
  }
  clearInput() {
    this.result = '';
  }
  backspace() {
    this.result = this.result.slice(0, -1);
  }
  handleKeydown(event) {
    const k = event.key;
    if (/\d/.test(k)) {
      this.result = `${this.result}${k}`;
      event.preventDefault();
      return;
    }
    if (['+', '-', '*', '/', '%', '.'].includes(k)) {
      this.result = `${this.result}${k}`;
      event.preventDefault();
      return;
    }
    if (k === 'Enter' || k === '=') {
      this.calculateResult();
      event.preventDefault();
      return;
    }
    if (k === 'Backspace') {
      this.backspace();
      event.preventDefault();
      return;
    }
    if (k === 'Escape') {
      this.clearInput();
      event.preventDefault();
    }
  }
}
