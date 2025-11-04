import { LightningElement, api } from 'lwc';
export default class ComboboxEditor extends LightningElement {
    @api editedValue;
    @api options;
    handleChange(event) {
        event.stopPropagation();
        this.editedValue = event.detail.value;
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: true,
            composed: true,
            detail: { value: this.editedValue },
        }));
    }

    @api
    get validity() {
        const c = this.template.querySelector('lightning-combobox');
        return c ? c.validity : { valid: true };
    }

    @api
    focus() {
        const c = this.template.querySelector('lightning-combobox');
        if (c) c.focus();
    }
}
