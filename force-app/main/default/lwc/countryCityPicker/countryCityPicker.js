import { LightningElement, wire } from 'lwc';
// 1. Import the Apex methods
import getCountries from '@salesforce/apex/DependentPicklistController.getCountries';
import getCities from '@salesforce/apex/DependentPicklistController.getCities';

export default class CountryCityPicker extends LightningElement {
    // Properties to hold the selected values
    selectedCountry;
    selectedCity;

    // Properties to hold the picklist options
    countryOptions = [];
    cityOptions = [];

    // 2. Wire to get the Country list automatically on load
    @wire(getCountries)
    wiredCountries({ error, data }) {
        if (data) {
            // Map the data (e.g., [ {Name: 'India'} ]) to the format
            // required by lightning-combobox (e.g., [ {label: 'India', value: 'India'} ])
            this.countryOptions = data.map(country => ({
                label: country.Name,
                value: country.Name
            }));
        } else if (error) {
            console.error('Error fetching countries:', error);
        }
    }

    // 3. Wire to get the City list.
    // This is REACTIVE: it will automatically re-run when 'selectedCountry' changes.
    @wire(getCities, { countryName: '$selectedCountry' })
    wiredCities({ error, data }) {
        if (data) {
            // Map the city data
            this.cityOptions = data.map(city => ({
                label: city.Name,
                value: city.Name
            }));
        } else if (error) {
            console.error('Error fetching cities:', error);
        }
    }

    // 4. When a country is selected...
    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
        // Reset the city selection and options
        this.selectedCity = null;
        this.cityOptions = []; // Clear the city list until the wire service returns new ones
    }

    // 5. When a city is selected...
    handleCityChange(event) {
        this.selectedCity = event.detail.value;
    }

    // 6. Getter to disable the city picklist
    // It's disabled if no country is selected. 
    get isCityDisabled() {
        return !this.selectedCountry;
    }
}