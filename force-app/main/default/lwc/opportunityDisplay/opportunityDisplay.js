import { LightningElement, api } from 'lwc';
export default class OpportunityDetailClone extends LightningElement {
    @api recordId;
    objectApiName = 'Opportunity';
}