import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import OPPORTUNITY_NAME from '@salesforce/schema/Opportunity.Name';
import OPPORTUNITY_STAGE_NAME from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPORTUNITY_CLOSE_DATE from '@salesforce/schema/Opportunity.CloseDate';

const FIELDS = [OPPORTUNITY_NAME, OPPORTUNITY_STAGE_NAME, OPPORTUNITY_AMOUNT, OPPORTUNITY_CLOSE_DATE];

export default class OpportunityDisplay extends LightningElement {
    @api recordId;
    opportunity;
    error;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.opportunity = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.opportunity = undefined;
        }
    }

    get name() {
        return this.opportunity.fields.Name.value;
    }

    get stageName() {
        return this.opportunity.fields.StageName.value;
    }

    get amount() {
        return this.opportunity.fields.Amount.value;
    }

    get closeDate() {
        return this.opportunity.fields.CloseDate.value;
    }
}
