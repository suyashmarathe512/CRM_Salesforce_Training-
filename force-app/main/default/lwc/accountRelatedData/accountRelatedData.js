import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import getAccounts from '@salesforce/apex/AccountContactOppController.getAccounts';
import getRelatedData from '@salesforce/apex/AccountContactOppController.getRelatedData';
import deleteSObjectRecord from '@salesforce/apex/AccountContactOppController.deleteSObjectRecord';
const RECORDS_PER_PAGE = 6;
const ACTION_EDIT = { label: 'Edit', name: 'edit' };
const ACTION_DELETE = { label: 'Delete', name: 'delete' };

export default class AccountRelatedData extends NavigationMixin(LightningElement) {
    @track accountOptions = [];
    selectedAccountId = '';
    @track sections = [
        { key: 'Contacts', title: 'Contacts', icon: 'standard:contact', allRecords: [], columns: [], permissions: {}, draftValues: [], currentPage: 1, pagedRecords: [], totalPages: 1, isFirstPage: true, isLastPage: true, displayTitle: 'Contacts (0)', updateKey: 0 },
        { key: 'Opportunities', title: 'Opportunities', icon: 'standard:opportunity', allRecords: [], columns: [], permissions: {}, draftValues: [], currentPage: 1, pagedRecords: [], totalPages: 1, isFirstPage: true, isLastPage: true, displayTitle: 'Opportunities (0)', updateKey: 0 }
    ];
    isLoading = false;
    wiredDataResult;
    recordsPerPage = RECORDS_PER_PAGE;
    @track stagePicklistValues = [];
    recordTypeId;
    isStageModalOpen = false;
    selectedStageValue = '';
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
    @wire(getObjectInfo, {objectApiName: OPPORTUNITY_OBJECT})
    wiredOppInfo(result) {
        if (result.data) {
            this.recordTypeId = result.data.defaultRecordTypeId;
            console.log('Opportunity Record Type ID:', this.recordTypeId);
            console.log('Opportunity Object Info:', result.data);
        } else if (result.error) {
            console.error('Error getting Opportunity Info:', result.error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STAGE_FIELD })
    wiredStagePlicklist(result) {
        if (result.data) {
            this.stagePicklistValues = result.data.values.map(entry => ({
                label: entry.label,
                value: entry.value
            }));
            this.refreshColumnsWithPicklist();
            console.log('Stage Picklist Values:', this.stagePicklistValues);
        } else if (result.error) {
            console.error('Error loading picklist:', result.error);
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
            this.sections[0].allRecords = data.contacts;
            this.sections[0].permissions = data.contactPermissions;
            this.sections[1].allRecords = data.opportunities;
            this.sections[1].permissions = data.oppPermissions;
            this.setupColumns(data);
            this.updateSectionComputedProperties();
            this.isLoading = false;
        } else if (error) {
            this.showToast('Error', 'Could not load related data.', 'error');
            this.isLoading = false;
        }
    }
    refreshColumnsWithPicklist() {
        if (this.wiredDataResult && this.wiredDataResult.data) {
            this.setupColumns(this.wiredDataResult.data);
        }
    }
    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        this.sections.forEach(section => {
            section.currentPage = 1;
        });
        this.updateSectionComputedProperties();
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
            this.sections.forEach(section => {
                section.draftValues = [];
                section.updateKey++;
            });
            await refreshApex(this.wiredDataResult);
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Could not update records.', 'error');
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
    }
    async handleDelete(row) {
        const recordId = row.Id;
        const isContact = recordId.startsWith('003');
        const section = this.sections.find(s => s.key === (isContact ? 'Contacts' : 'Opportunities'));
        const perms = section.permissions;

        if (!perms.canDelete) {
            this.showToast('Permission Denied', 'You do not have permission to delete.', 'error');
            return;
        }
        this.isLoading = true;
        try {
            await deleteSObjectRecord({ recordId: recordId });
            this.showToast('Success', 'Record deleted successfully.', 'success');
            await refreshApex(this.wiredDataResult);
        } catch (error) {
            this.showToast('Error Deleting', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    handlePageChange(event) {
        const sectionKey = event.target.dataset.section;
        const direction = event.target.dataset.direction;
        const section = this.sections.find(s => s.key === sectionKey);
        const totalPages = Math.max(Math.ceil(section.allRecords.length / this.recordsPerPage), 1);
        if (direction === 'previous' && section.currentPage > 1) {
            section.currentPage--;
        } else if (direction === 'next' && section.currentPage < totalPages) {
            section.currentPage++;
        }
        this.updateSectionComputedProperties();
    }
    updateSectionComputedProperties() {
        this.sections.forEach(section => {
            const start = (section.currentPage - 1) * this.recordsPerPage;
            const end = section.currentPage * this.recordsPerPage;
            section.pagedRecords = section.allRecords.slice(start, end);
            section.totalPages = Math.max(Math.ceil(section.allRecords.length / this.recordsPerPage), 1);
            section.isFirstPage = section.currentPage === 1;
            section.isLastPage = section.currentPage === section.totalPages;
            const totalCount = section.allRecords.length;
            const displayCount = totalCount > 6 ? '6+' : totalCount;
            section.displayTitle = `${section.title} (${displayCount})`;
        });
    }
    setupColumns(data) {
        this.sections.forEach(section => {
            const actions = [];
            if (section.permissions.canEdit) {
                actions.push(ACTION_EDIT);
            }
            if (section.permissions.canDelete) {
                actions.push(ACTION_DELETE);
            }
            const columnKey = section.key === 'Contacts' ? 'contactColumns' : 'opportunityColumns';
            let columns = [...data[columnKey]];
            columns.forEach((col, index) => {
                if (col.type === 'date-local') {
                    columns[index] = { 
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
            const stageNameIndex = columns.findIndex(col => col.fieldName === 'StageName');
            if (stageNameIndex !== -1 && section.key === 'Opportunities') {
                columns[stageNameIndex] = {
                    label: 'Stage',
                    fieldName: 'StageName',
                    type: 'picklistType',
                    editable: section.permissions.canEdit,
                    typeAttributes: {
                        options: this.stagePicklistValues,
                        value: { fieldName: 'StageName' },
                        fieldName: 'StageName',
                        context: { fieldName: 'Id' }
                    }
                };
            }
            if (actions.length > 0) {
                section.columns = [...columns, {
                    type: 'action',
                    typeAttributes: { rowActions: actions }
                }];
            } else {
                section.columns = columns;
            }
        });
    }
    get contactsSection() {
        return this.sections[0];
    }
    get opportunitiesSection() {
        return this.sections[1];
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
