import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getAccounts from '@salesforce/apex/AccountContactOppController.getAccounts';
import getRelatedData from '@salesforce/apex/AccountContactOppController.getRelatedData';
import deleteSObjectRecord from '@salesforce/apex/AccountContactOppController.deleteSObjectRecord';
const RECORDS_PER_PAGE = 6;
const ACTION_EDIT = { label: 'Edit', name: 'edit' };
const ACTION_DELETE = { label: 'Delete', name: 'delete' };
export default class AccountContactOppViewer extends NavigationMixin(LightningElement) {
    @track accountOptions = [];
    selectedAccountId = '';
    @track sections = [
        { key: 'contacts', title: 'Contacts', icon: 'standard:contact', allRecords: [], columns: [], permissions: {}, draftValues: [], currentPage: 1, pagedRecords: [], totalPages: 1, isFirstPage: true, isLastPage: true, displayTitle: 'Contacts (0)', updateKey: 0 },
        { key: 'opportunities', title: 'Opportunities', icon: 'standard:opportunity', allRecords: [], columns: [], permissions: {}, draftValues: [], currentPage: 1, pagedRecords: [], totalPages: 1, isFirstPage: true, isLastPage: true, displayTitle: 'Opportunities (0)', updateKey: 0 }
    ];
    isLoading = false;
    wiredDataResult;
    recordsPerPage = RECORDS_PER_PAGE;
    connectedCallback() {
        document.addEventListener('visibilitychange', this.handleVisibilityChange);
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
    handleAccountChange(event) {
        this.isLoading = true;
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
        const section = this.sections.find(s => s.key === (isContact ? 'contacts' : 'opportunities'));
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
            const columnKey = section.key === 'contacts' ? 'contactColumns' : 'opportunityColumns';
            let columns = [...data[columnKey]];
            columns.forEach((col, index) => {
                if (col.type === 'date-local') {
                    columns[index] = { ...col, type: 'date', typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit' } };
                }
            });
            const stageNameIndex = columns.findIndex(col => col.fieldName === 'StageName');
            if (stageNameIndex !== -1 && section.permissions.canEdit) {
                columns[stageNameIndex] = { ...columns[stageNameIndex], type: 'picklist', editable: true, typeAttributes: { options: [
                    { label: 'Prospecting', value: 'Prospecting' },
                    { label: 'Qualification', value: 'Qualification' },
                    { label: 'Needs Analysis', value: 'Needs Analysis' },
                    { label: 'Value Proposition', value: 'Value Proposition' },
                    { label: 'Id. Decision Makers', value: 'Id. Decision Makers' },
                    { label: 'Perception Analysis', value: 'Perception Analysis' },
                    { label: 'Proposal/Price Quote', value: 'Proposal/Price Quote' },
                    { label: 'Negotiation/Review', value: 'Negotiation/Review' },
                    { label: 'Closed Won', value: 'Closed Won' },
                    { label: 'Closed Lost', value: 'Closed Lost' }
                ] } };
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
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}