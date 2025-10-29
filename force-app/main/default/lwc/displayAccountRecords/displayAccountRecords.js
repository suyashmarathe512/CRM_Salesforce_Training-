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
  @track offsetSize = 0;
  loadedCount = 0;
  allLoaded = false;
  sortedBy = 'Name';
  sortedDirection = 'asc';
  pageSize = 20;
  _scrollContainer;
  _isLoading = false;
  @wire(getAccounts, {
    limitSize: '$pageSize',
    offsetSize: '$offsetSize',
    sortBy: '$sortedBy',
    sortDirection: '$sortedDirection'
  })
  wired({ data, error }) {
    if (error) {
      this._isLoading = false;
      return;
    }
    if (!data) return;
    const incoming = (data.rows || []).map(r => ({ ...r, recordUrl: '/' + r.Id }));
    this.data = this.offsetSize > 0 ? [...this.data, ...incoming] : incoming;
    this.loadedCount = this.data.length;
    const total = data.totalCount || 0;
    this.allLoaded = this.data.length >= total;
    this._isLoading = false;
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
  renderedCallback() {
    if (!this._scrollContainer) {
      this._scrollContainer = this.template.querySelector('.dt-scroll');
      if (this._scrollContainer) {
        this._scrollContainer.addEventListener('scroll', this.handleScroll.bind(this));
      }
    }
  }
  handleScroll(event) {
    if (this.allLoaded || this._isLoading) return;

    const { scrollTop, scrollHeight, clientHeight } = event.target;
    if (scrollTop + clientHeight >= scrollHeight - 10) {
      this.loadMoreData();
    }
  }

  loadMoreData() {
    this._isLoading = true;
    this.offsetSize += this.pageSize;
  }

}
