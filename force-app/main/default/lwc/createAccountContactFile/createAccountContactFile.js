import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Import Apex methods
import saveRecords from '@salesforce/apex/AccountContactFileController.saveRecords';
import getCountries from '@salesforce/apex/AccountContactFileController.getCountries';
import getCities from '@salesforce/apex/AccountContactFileController.getCities';

export default class CreateAccountContactFile extends NavigationMixin(LightningElement) {
    // Form field properties
    @track accName = '';
    @track accWebsite = '';
    @track conFName = '';
    @track conLName = '';
    @track conEmail = '';
    @track conPhone = '';
    
    // Picklist properties
    @track selectedCountry = '';
    @track selectedCity = '';
    @track countryOptions = [];
    @track cityOptions = [];
    @track isCityDisabled = true;

    // File properties
    @track fileData; // Will hold { base64, filename }

    // Utility properties
    @track isLoading = false;

    // Load the initial Country picklist values
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            this.countryOptions = data;
        } else if (error) {
            this.showToast('Error', 'Failed to load countries: ' + error.body.message, 'error');
        }
    }

    // Generic handler for all text/email/phone/url inputs
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

    // Handler for Country picklist change
    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
        this.selectedCity = ''; // Reset city
        this.isCityDisabled = true;
        this.cityOptions = []; // Clear old city options

        if (this.selectedCountry) {
            this.isLoading = true;
            // Call Apex to get cities for the selected country
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

    // Handler for City picklist change
    handleCityChange(event) {
        this.selectedCity = event.detail.value;
    }

    // Handler for file selection
    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                // result contains the file as a data URL
                const base64 = reader.result.split(',')[1];
                this.fileData = {
                    'base64': base64,
                    'filename': file.name
                };
            };
            reader.readAsDataURL(file);
        } else {
            this.fileData = null;
        }
    }

    // --- Button Click Handlers ---

    // (d) Save and Navigate
    handleSave() {
        this.saveData(true); // true = navigate after save
    }

    // (e) Save and clear form
    handleSaveAndNew() {
        this.saveData(false); // false = do not navigate
    }

    // (f) Clear all form fields
    handleCancel() {
        this.accName = '';
        this.accWebsite = '';
        this.conFName = '';
        this.conLName = '';
        this.conEmail = '';
        this.conPhone = '';
        this.selectedCountry = '';
        this.selectedCity = '';
        this.fileData = null;
        this.isCityDisabled = true;
        this.cityOptions = [];

        // Reset the file input visually
        const fileInput = this.template.querySelector('lightning-input[type="file"]');
        if (fileInput) {
            fileInput.value = null;
        }
    }

    // --- Helper Functions ---

    // Core logic for saving data
    saveData(shouldNavigate) {
        // Simple Validation
        if (!this.accName || !this.conLName) {
            this.showToast('Error', 'Please fill in required fields: Account Name and Contact Last Name.', 'error');
            return;
        }

        this.isLoading = true;

        // Prepare file data
        const base64 = this.fileData ? this.fileData.base64 : null;
        const filename = this.fileData ? this.fileData.filename : null;

        // Call Apex
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
                // Navigate to the new Contact record page
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: contactId,
                        actionName: 'view'
                    }
                });
            }
            
            // Clear the form for "Save & New" or after navigation (for a clean state if user clicks back)
            this.handleCancel();
            
        })
        .catch(error => {
            this.isLoading = false;
            this.showToast('Error', 'Error creating records: ' + error.body.message, 'error');
        });
    }

    // Helper to show toasts
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}