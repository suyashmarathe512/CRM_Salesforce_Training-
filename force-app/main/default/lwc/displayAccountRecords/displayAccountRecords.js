import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/GetAccounts.getAccounts';
const COLUMNS = [
  { label: 'Account Name', fieldName: 'recordUrl', type: 'url', sortable: true, typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
  { label: 'Phone', fieldName: 'Phone', type: 'phone', sortable: true },
  { label: 'Industry', fieldName: 'Industry', type: 'text', sortable: true },
  { label: 'Rating', fieldName: 'Rating', type: 'text', sortable: true },
  { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency', sortable: true, cellAttributes: { alignment: 'right' } },
  { label: 'Owner', fieldName: 'OwnerName', type: 'text', sortable: true }
];
export default class AccountList extends LightningElement {
  columns = COLUMNS;
  @track data = [];
  loadedCount = 0;
  allLoaded = false;
  pageSize = 20;
  offsetSize = 0;
  sortedBy = 'Name';
  sortedDirection = 'asc';
  _loadMoreTable;
  _loadTimeout;
  @wire(getAccounts, {
    limitSize: '$pageSize',
    offsetSize: '$offsetSize',
    sortBy: '$sortedBy',
    sortDirection: '$sortedDirection'
  })
  wired({ data, error }) {
    if (error) {
      this._clearLoadMoreSpinner();
      return;
    }
    if (!data) return;
    const incoming = (data.rows || []).map(r => ({ ...r, recordUrl: '/' + r.Id }));
    this.data = this.offsetSize > 0 ? [...this.data, ...incoming] : incoming;
    this.loadedCount = this.data.length;
    const total = data.totalCount || 0;
    this.allLoaded = this.data.length >= total;

    this._clearLoadMoreSpinner();
  }
  handleLoadMore(event) {
    if (this.allLoaded) return;

    this._loadMoreTable = event.target;
    this._loadMoreTable.isLoading = true;

    const prevOffset = this.offsetSize;
    this.offsetSize = prevOffset + this.pageSize;

    clearTimeout(this._loadTimeout);
    this._loadTimeout = setTimeout(() => {
      if (this._loadMoreTable) {
        this._loadMoreTable.isLoading = false;
        this._loadMoreTable = null;
      }
      this.offsetSize = prevOffset;
    }, 10000);
  }

  handleSort(event) {
    const { fieldName, sortDirection } = event.detail;
    this.sortedBy = fieldName === 'recordUrl' ? 'Name' : fieldName;
    this.sortedDirection = sortDirection;
    this.offsetSize = 0;
    this.data = [];
    this.loadedCount = 0;
    this.allLoaded = false;
  }

  _clearLoadMoreSpinner() {
    if (this._loadTimeout) {
      clearTimeout(this._loadTimeout);
      this._loadTimeout = null;
    }
    if (this._loadMoreTable) {
      this._loadMoreTable.isLoading = false;
      this._loadMoreTable = null;
    }
  }
}
