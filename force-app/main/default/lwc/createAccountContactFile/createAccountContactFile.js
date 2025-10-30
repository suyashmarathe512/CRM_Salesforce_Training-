import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveRecords from '@salesforce/apex/AccountContactFileController.saveRecords';
import getCountries from '@salesforce/apex/AccountContactFileController.getCountries';
import getCities from '@salesforce/apex/AccountContactFileController.getCities';
export default class CreateAccountContactFile extends NavigationMixin(LightningElement) {
    @track accName = '';
    @track accWebsite = '';
    @track conFName = '';
    @track conLName = '';
    @track conEmail = '';
    @track conPhone = '';
    @track selectedCountry = '';
    @track selectedCity = '';
    @track countryOptions = [];
    @track cityOptions = [];
    @track isCityDisabled = true;
    @track fileData;
    @track fileName = '';
    @track isLoading = false;
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            this.countryOptions = data;
        } else if (error) {
            this.showToast('Error', 'Failed to load countries: ' + error.body.message, 'error');
        }
    }
    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'accName') {
            this.accName = event.target.value;
        } else if (field === 'accWebsite') {
            this.accWebsite = event.target.value;
        } else if (field === 'conFName') {
            this.conFName = event.target.value;
        } else if (field === 'conLName') {
            this.conLName = event.target.value;
        } else if (field === 'conEmail') {
            this.conEmail = event.target.value;
        } else if (field === 'conPhone') {
            this.conPhone = event.target.value;
        }
    }
    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
        this.selectedCity = '';
        this.isCityDisabled = true;
        this.cityOptions = [];
        if (this.selectedCountry) {
            this.isLoading = true;
            getCities({ country: this.selectedCountry })
                .then(result => {
                    this.cityOptions = result;
                    this.isCityDisabled = false;
                    this.isLoading = false;
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to load cities: ' + error.body.message, 'error');
                    this.isLoading = false;
                });
        }
    }
    handleCityChange(event) {
        this.selectedCity = event.detail.value;
    }
    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                this.fileData = {
                    'base64': base64,
                    'filename': file.name
                };
                this.fileName = file.name;
            };
            reader.readAsDataURL(file);
        } else {
            this.fileData = null;
            this.fileName = '';
        }
    }
    handleSave() {
        this.saveData(true);
    }
    handleSaveAndNew() {
        this.saveData(false);
    }
    handleCancel() {
        this.accName = '';
        this.accWebsite = '';
        this.conFName = '';
        this.conLName = '';
        this.conEmail = '';
        this.conPhone = '';
        this.selectedCountry = '';
        this.selectedCity = '';
        this.isCityDisabled = true;
        this.cityOptions = [];
        this.handleRemoveFile();
    }
    handleRemoveFile() {
        this.fileName = '';
        this.fileData = null;
        const fileInput = this.template.querySelector('lightning-input[type="file"]');
        if (fileInput) {
            fileInput.value = null;
        }
    }
    saveData(shouldNavigate) {
        if (!this.accName || !this.conLName) {
            this.showToast('Error', 'Please fill in required fields: Account Name and Contact Last Name.', 'error');
            return;
        }
        this.isLoading = true;
        const base64 = this.fileData ? this.fileData.base64 : null;
        const filename = this.fileData ? this.fileData.filename : null;
        saveRecords({
            accName: this.accName,
            accWebsite: this.accWebsite,
            conFName: this.conFName,
            conLName: this.conLName,
            conEmail: this.conEmail,
            conPhone: this.conPhone,
            country: this.selectedCountry,
            city: this.selectedCity,
            base64Data: base64,
            fileName: filename
        })
        .then(contactId => {
            this.isLoading = false;
            this.showToast('Success', 'Records created successfully!', 'success');
            if (shouldNavigate) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: contactId,
                        actionName: 'view'
                    }
                });
            }
            this.handleCancel();
        })
        .catch(error => {
            this.isLoading = false;
            this.showToast('Error', 'Error creating records: ' + error.body.message, 'error');
        });
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
