import LightningDatatable from 'lightning/datatable';
import displayTpl from './datatablePicklistDisplay.html';
import editTpl from './datatablePicklistEdit.html';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: displayTpl,
            editTemplate: editTpl,
            standardCellLayout: true,
            typeAttributes: ['options', 'value', 'placeholder', 'context', 'disabled']
        }
    };
}
