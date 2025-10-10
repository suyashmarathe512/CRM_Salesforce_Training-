import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/GetAccounts.getAllAccounts';

export default class AccountList extends LightningElement {
    accounts;
    error;
    columns = [
       { label: 'Account Name', fieldName: 'AccountLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
        { label: 'Type', fieldName: 'Type', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },  
        {label: 'Website',fieldName: 'Website',type: 'url',typeAttributes: { label: { fieldName: 'Website' }, target: '_blank' }},
        { label: 'Industry', fieldName: 'Industry', type: 'text' },
        { label: 'Rating', fieldName: 'Rating', type: 'text' },
        { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency' },
        { label: 'Owner Id', fieldName: 'OwnerId', type: 'text' }
    ];

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data.map(account => {
                return {
                    ...account,
                    AccountLink: '/' + account.Id
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.accounts = undefined;
        }
    }
}
