import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation'; // For opening the edit page

// Import all our Apex methods
import getAccounts from '@salesforce/apex/AccountContactOppController.getAccounts';
import getRelatedData from '@salesforce/apex/AccountContactOppController.getRelatedData';
import deleteSObjectRecord from '@salesforce/apex/AccountContactOppController.deleteSObjectRecord';

const RECORDS_PER_PAGE = 6;
const ACTION_EDIT = { label: 'Edit', name: 'edit' };
const ACTION_DELETE = { label: 'Delete', name: 'delete' };

export default class AccountContactOppViewer extends NavigationMixin(LightningElement) {
    // --- All your existing properties ---
    @track accountOptions = [];
    selectedAccountId = '';
    @track allContacts = [];
    @track allOpportunities = [];
    @track contactColumns = [];
    @track oppColumns = [];
    contactPermissions = {};
    oppPermissions = {};
    isLoading = false;
    wiredDataResult; 
    contactDraftValues = [];
    oppDraftValues = [];
    @track contactCurrentPage = 1;
    @track oppCurrentPage = 1;
    recordsPerPage = RECORDS_PER_PAGE;

    // --- NEW: Code to Refresh After Edit ---

    // This is a standard LWC function that runs when the component is first added to the page.
    connectedCallback() {
        // We tell the browser: "Hey, when the user looks at this tab, run my 'handleVisibilityChange' function."
        // This is how we know the user closed the edit modal and came back.
        document.addEventListener('visibilitychange', this.handleVisibilityChange);
    }

    // This is a standard LWC function that runs when the component is removed.
    disconnectedCallback() {
        // This just cleans up the listener to prevent memory leaks.
        document.removeEventListener('visibilitychange', this.handleVisibilityChange);
    }

    // This is our function that runs when the tab becomes visible.
    // We use "() =>" (an arrow function) to make sure "this" still refers to our component.
    handleVisibilityChange = () => {
        // We only refresh if:
        // 1. The tab is now visible (not hidden).
        // 2. We actually have data to refresh (this.wiredDataResult exists).
        if (document.visibilityState === 'visible' && this.wiredDataResult) {
            this.isLoading = true;
            
            // This is the same refresh function we use everywhere else.
            refreshApex(this.wiredDataResult).finally(() => {
                this.isLoading = false;
            });
        }
    }
    // --- End of New Code ---


    // --- Get All Accounts (No Change) ---
    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accountOptions = data.map(account => ({
                label: account.Name,
                value: account.Id
            }));
        } else if (error) {
            this.showToast('Error', 'Could not load accounts.', 'error');
        }
    }

    // --- Get Related Data (No Change) ---
    @wire(getRelatedData, { accountId: '$selectedAccountId' })
    wiredData(result) {
        this.wiredDataResult = result; 
        const { data, error } = result;

        if (data) {
            this.allContacts = data.contacts;
            this.allOpportunities = data.opportunities;
            this.contactPermissions = data.contactPermissions;
            this.oppPermissions = data.oppPermissions;
            this.setupColumns(data);
            this.contactCurrentPage = 1;
            this.oppCurrentPage = 1;
            this.isLoading = false;
        } else if (error) {
            this.showToast('Error', 'Could not load related data.', 'error');
            this.isLoading = false;
        }
    }

    // --- Event Handlers (No Change) ---

    handleAccountChange(event) {
        this.isLoading = true;
        this.selectedAccountId = event.detail.value;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'edit':
                this.handleEdit(row.Id);
                break;
            case 'delete':
                this.handleDelete(row);
                break;
            default:
        }
    }

    async handleSave(event) {
        this.isLoading = true;
        const draftValues = event.detail.draftValues;
        
        const recordInputs = draftValues.map(draft => ({ fields: draft }));
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));

        try {
            await Promise.all(promises);
            this.showToast('Success', 'Records updated successfully.', 'success');
            
            this.contactDraftValues = [];
            this.oppDraftValues = [];

            // This refresh handles *inline* edits
            await refreshApex(this.wiredDataResult);

        } catch (error) {
            this.showToast('Error', 'Could not update records.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // --- Edit and Delete Logic (No Change) ---

    handleEdit(recordId) {
        // This opens the modal
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'edit'
            }
        });
        // Our new 'handleVisibilityChange' function will automatically
        // handle refreshing the data when this modal is closed.
    }

    async handleDelete(row) {
        const recordId = row.Id;
        const isContact = recordId.startsWith('003');
        const perms = isContact ? this.contactPermissions : this.oppPermissions;

        if (!perms.canDelete) {
            this.showToast('Permission Denied', 'You do not have permission to delete.', 'error');
            return;
        }

        this.isLoading = true;
        try {
            await deleteSObjectRecord({ recordId: recordId });
            this.showToast('Success', 'Record deleted successfully.', 'success');
            
            // This refresh handles deletes
            await refreshApex(this.wiredDataResult);
        } catch (error) {
            this.showToast('Error Deleting', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }


    // --- Pagination Logic (No Change) ---

    get pagedContacts() {
        const start = (this.contactCurrentPage - 1) * this.recordsPerPage;
        const end = this.contactCurrentPage * this.recordsPerPage;
        return this.allContacts.slice(start, end);
    }
    get pagedOpportunities() {
        const start = (this.oppCurrentPage - 1) * this.recordsPerPage;
        const end = this.oppCurrentPage * this.recordsPerPage;
        return this.allOpportunities.slice(start, end);
    }
    get totalContactPages() { return Math.max(Math.ceil(this.allContacts.length / this.recordsPerPage), 1); }
    get totalOppPages() { return Math.max(Math.ceil(this.allOpportunities.length / this.recordsPerPage), 1); }
    get isContactFirstPage() { return this.contactCurrentPage === 1; }
    get isContactLastPage() { return this.contactCurrentPage === this.totalContactPages; }
    get isOppFirstPage() { return this.oppCurrentPage === 1; }
    get isOppLastPage() { return this.oppCurrentPage === this.totalOppPages; }
    get contactTitle() { return `Contacts (${this.allContacts.length})`; }
    get oppTitle() { return `Opportunities (${this.allOpportunities.length})`; }
    handleContactPrevious() { this.contactCurrentPage--; }
    handleContactNext() { this.contactCurrentPage++; }
    handleOppPrevious() { this.oppCurrentPage--; }
    handleOppNext() { this.oppCurrentPage++; }


    // --- Helper Functions (No Change) ---

    setupColumns(data) {
        const contactActions = [];
        if (data.contactPermissions.canEdit) {
            contactActions.push(ACTION_EDIT);
        }
        if (data.contactPermissions.canDelete) {
            contactActions.push(ACTION_DELETE);
        }
        
        if (contactActions.length > 0) {
            this.contactColumns = [...data.contactColumns, {
                type: 'action',
                typeAttributes: { rowActions: contactActions }
            }];
        } else {
            this.contactColumns = data.contactColumns;
        }

        const oppActions = [];
        if (data.oppPermissions.canEdit) {
            oppActions.push(ACTION_EDIT);
        }
        if (data.oppPermissions.canDelete) {
            oppActions.push(ACTION_DELETE);
        }

        if (oppActions.length > 0) {
            this.oppColumns = [...data.opportunityColumns, {
                type: 'action',
                typeAttributes: { rowActions: oppActions }
            }];
        } else {
            this.oppColumns = data.opportunityColumns;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}

