import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import OPPORTUNITY_STAGE_NAME from '@salesforce/schema/Opportunity.StageName';
import getAccounts from '@salesforce/apex/AccountContactOppController.getAccounts';
import getRelatedData from '@salesforce/apex/AccountContactOppController.getRelatedData';
import deleteSObjectRecord from '@salesforce/apex/AccountContactOppController.deleteSObjectRecord';
const RECORDS_PER_PAGE = 6;
const ACTION_EDIT = { label: 'Edit', name: 'edit' };
const ACTION_DELETE = { label: 'Delete', name: 'delete' };
export default class AccountRelatedData extends NavigationMixin(LightningElement) {
    @track accountOptions = [];
    selectedAccountId = '';
    @track contactsAllRecords = [];
    @track contactsColumns = [];
    @track contactsPermissions = {};
    @track contactsDraftValues = [];
    @track contactsCurrentPage = 1;
    @track contactsPagedRecords = [];
    @track contactsTotalPages = 1;
    @track contactsIsFirstPage = true;
    @track contactsIsLastPage = true;
    @track contactsDisplayTitle = 'Contacts (0)';
    @track opportunitiesAllRecords = [];
    @track opportunitiesColumns = [];
    @track opportunitiesPermissions = {};
    @track opportunitiesDraftValues = [];
    @track opportunitiesCurrentPage = 1;
    @track opportunitiesPagedRecords = [];
    @track opportunitiesTotalPages = 1;
    @track opportunitiesIsFirstPage = true;
    @track opportunitiesIsLastPage = true;
    @track opportunitiesDisplayTitle = 'Opportunities (0)';
    @track stageOptions = [];
    defaultRecordTypeId;
    isLoading = false;
    wiredDataResult;
    recordsPerPage = RECORDS_PER_PAGE;
    connectedCallback() {
        document.addEventListener('visibilitychange', this.handleVisibilityChange);

    }
    disconnectedCallback() {
        document.removeEventListener('visibilitychange', this.handleVisibilityChange);
    }
    handleVisibilityChange = () => {
        if (document.visibilityState === 'visible' && this.wiredDataResult) {
            this.isLoading = true;
            refreshApex(this.wiredDataResult).finally(() => {
                this.isLoading = false;
            });
        }
    }
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
    @wire(getRelatedData, { accountId: '$selectedAccountId' })
    wiredData(result) {
        this.wiredDataResult = result;
        const { data, error } = result;
        if (data) {
            this.contactsAllRecords = data.contacts;
            this.contactsPermissions = data.contactPermissions;
            this.opportunitiesAllRecords = data.opportunities;
            this.opportunitiesPermissions = data.oppPermissions;
            this.setupColumns(data);
            this.updateComputedProperties();
            this.isLoading = false;
        } else if (error) {
            this.showToast('Error', 'Could not load related data.', 'error');
            this.isLoading = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error('Error loading object info:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: OPPORTUNITY_STAGE_NAME })
    wiredStageOptions({ error, data }) {
        if (data) {
            this.stageOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            console.error('Error loading stage options:', error);
        }
    }
    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        this.contactsCurrentPage = 1;
        this.opportunitiesCurrentPage = 1;
        this.updateComputedProperties();
    }
    handleContactsRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.handleEdit(row.Id);
                break;
            case 'delete':
                this.handleContactsDelete(row);
                break;
            default:
        }
    }
    handleOpportunitiesRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.handleEdit(row.Id);
                break;
            case 'delete':
                this.handleOpportunitiesDelete(row);
                break;
            default:
        }
    }
    async handleContactsSave(event) {
        this.isLoading = true;
        const draftValues = event.detail.draftValues;
        const recordInputs = draftValues.map(draft => ({ fields: draft }));
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        try {
            await Promise.all(promises);
            this.showToast('Success', 'Contacts updated successfully.', 'success');
            this.contactsDraftValues = [];
            await refreshApex(this.wiredDataResult);
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Could not update contacts.', 'error');
        } finally {
            this.isLoading = false;
        }
    }
    async handleOpportunitiesSave(event) {
        this.isLoading = true;
        const draftValues = event.detail.draftValues;
        const recordInputs = draftValues.map(draft => ({ fields: draft }));
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        try {
            await Promise.all(promises);
            this.showToast('Success', 'Opportunities updated successfully.', 'success');
            this.opportunitiesDraftValues = [];
            await refreshApex(this.wiredDataResult);
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Could not update opportunities.', 'error');
        } finally {
            this.isLoading = false;
        }
    }
    handleEdit(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'edit'
            }
        });
        refreshApex(this.wiredDataResult);
    }
    async handleContactsDelete(row) {
        this.isLoading = true;
        try {
            await deleteSObjectRecord({ recordId: row.Id });
            this.showToast('Success', 'Contact deleted successfully.', 'success');
            await refreshApex(this.wiredDataResult);
        } catch (error) {
            this.showToast('Error Deleting', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    async handleOpportunitiesDelete(row) {
        this.isLoading = true;
        try {
            await deleteSObjectRecord({ recordId: row.Id });
            this.showToast('Success', 'Opportunity deleted successfully.', 'success');
            await refreshApex(this.wiredDataResult);
        } catch (error) {
            this.showToast('Error Deleting', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    handleContactsPageChange(event) {
        const direction = event.target.dataset.direction;
        const totalPages = this.contactsTotalPages;
        if (direction === 'previous' && this.contactsCurrentPage > 1) {
            this.contactsCurrentPage--;
        } else if (direction === 'next' && this.contactsCurrentPage < totalPages) {
            this.contactsCurrentPage++;
        }
        this.updateContactsComputedProperties();
    }
    handleOpportunitiesPageChange(event) {
        const direction = event.target.dataset.direction;
        const totalPages = this.opportunitiesTotalPages;
        if (direction === 'previous' && this.opportunitiesCurrentPage > 1) {
            this.opportunitiesCurrentPage--;
        } else if (direction === 'next' && this.opportunitiesCurrentPage < totalPages) {
            this.opportunitiesCurrentPage++;
        }
        this.updateOpportunitiesComputedProperties();
    }
    updateComputedProperties() {
        this.updateContactsComputedProperties();
        this.updateOpportunitiesComputedProperties();
    }
    updateContactsComputedProperties() {
        const start = (this.contactsCurrentPage - 1) * this.recordsPerPage;
        const end = this.contactsCurrentPage * this.recordsPerPage;
        this.contactsPagedRecords = this.contactsAllRecords.slice(start, end);
        this.contactsTotalPages = Math.max(Math.ceil(this.contactsAllRecords.length / this.recordsPerPage), 1);
        this.contactsIsFirstPage = this.contactsCurrentPage === 1;
        this.contactsIsLastPage = this.contactsCurrentPage === this.contactsTotalPages;
        const totalCount = this.contactsAllRecords.length;
        const displayCount = totalCount > 6 ? '6+' : totalCount;
        this.contactsDisplayTitle = `Contacts (${displayCount})`;
    }
    updateOpportunitiesComputedProperties() {
        const start = (this.opportunitiesCurrentPage - 1) * this.recordsPerPage;
        const end = this.opportunitiesCurrentPage * this.recordsPerPage;
        this.opportunitiesPagedRecords = this.opportunitiesAllRecords.slice(start, end);
        this.opportunitiesTotalPages = Math.max(Math.ceil(this.opportunitiesAllRecords.length / this.recordsPerPage), 1);
        this.opportunitiesIsFirstPage = this.opportunitiesCurrentPage === 1;
        this.opportunitiesIsLastPage = this.opportunitiesCurrentPage === this.opportunitiesTotalPages;
        const totalCount = this.opportunitiesAllRecords.length;
        const displayCount = totalCount > 6 ? '6+' : totalCount;
        this.opportunitiesDisplayTitle = `Opportunities (${displayCount})`;
    }
    setupColumns(data) {
    const contactsActions = [];
    if (this.contactsPermissions.canEdit) {
        contactsActions.push(ACTION_EDIT);
    }
    if (this.contactsPermissions.canDelete) {
        contactsActions.push(ACTION_DELETE);
    }
    let contactsColumns = [...data.contactColumns];
    contactsColumns.forEach((col, index) => {
        if (col.type === 'date-local') {
            contactsColumns[index] = {
                ...col,
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                }
            };
        }
    });
    if (contactsActions.length > 0) {
        this.contactsColumns = [...contactsColumns, {
            type: 'action',
            typeAttributes: { rowActions: contactsActions }
        }];
    } else {
        this.contactsColumns = contactsColumns;
    }
    const opportunitiesActions = [];
    if (this.opportunitiesPermissions.canEdit) {
        opportunitiesActions.push(ACTION_EDIT);
    }
    if (this.opportunitiesPermissions.canDelete) {
        opportunitiesActions.push(ACTION_DELETE);
    }
    
    let opportunitiesColumns = [...data.opportunityColumns];
    opportunitiesColumns.forEach((col, index) => {
        if (col.type === 'date-local') {
            opportunitiesColumns[index] = {
                ...col,
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                }
            };
        }
    });
    const stageNameIndex = opportunitiesColumns.findIndex(col => col.fieldName === 'StageName');
    if (stageNameIndex !== -1) {
        opportunitiesColumns[stageNameIndex] = {
            label: 'Stage',
            fieldName: 'StageName',
            type: 'combobox',
            editable: this.opportunitiesPermissions.canEdit,
            typeAttributes: {
                options: this.stageOptions
            }
        };
    }
    console.log('Stage options: ', this.stageOptions);

    if (opportunitiesActions.length > 0) {
        this.opportunitiesColumns = [...opportunitiesColumns, {
            type: 'action',
            typeAttributes: { rowActions: opportunitiesActions }
        }];
    } else {
        this.opportunitiesColumns = opportunitiesColumns;
    }
}
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}