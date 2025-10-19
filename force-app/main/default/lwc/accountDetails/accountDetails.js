import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Account.Name', 'Account.Type', 'Account.Industry'];

export default class AccountDetails extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account;

    get name() {
        return this.account.data ? this.account.data.fields.Name.value : '';
    }

    get type() {
        return this.account.data ? this.account.data.fields.Type.value : '';
    }

    get industry() {
        return this.account.data ? this.account.data.fields.Industry.value : '';
    }
}
