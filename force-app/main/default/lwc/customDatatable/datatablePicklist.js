import { LightningElement, api } from 'lwc';
export default class DatatablePicklist extends LightningElement {
    @api value;
    @api typeAttributes;
    handleChange(event) {
        this.dispatchEvent(
            new CustomEvent('privateeditcustomcell', {
                bubbles: true,
                composed: true,
                detail: { value: event.detail.value }
            })
        );
    }
}


