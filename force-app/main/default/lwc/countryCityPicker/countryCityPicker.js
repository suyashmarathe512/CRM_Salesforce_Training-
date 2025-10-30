import { LightningElement, wire } from 'lwc';
import getCountries from '@salesforce/apex/DependentPicklistController.getCountries';
import getCities from '@salesforce/apex/DependentPicklistController.getCities';
export default class CountryCityPicker extends LightningElement{
    selectedCountry;
    selectedCity;
    countryOptions = [];
    cityOptions = [];
    @wire(getCountries)
    wiredCountries({error,data}){
        if (data) {
            this.countryOptions = data.map(country =>({
                label: country.Name,
                value: country.Name
            }));
        } else if (error){
            console.error('Error fetching countries:', error);
        }
    }
    @wire(getCities, {countryName: '$selectedCountry'})
    wiredCities({ error, data }){
        if (data){
            this.cityOptions = data.map(city => ({
                label: city.Name,
                value: city.Name
            }));
        }else if (error){
            console.error('Error fetching cities:', error);
        }
    }
    handleCountryChange(event){
        this.selectedCountry = event.detail.value;
        this.selectedCity = null;
        this.cityOptions = [];
    }
    handleCityChange(event){
        this.selectedCity = event.detail.value;
    }
    get isCityDisabled(){
        return !this.selectedCountry;
    }
}