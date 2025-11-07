import LightningDatatable from 'lightning/datatable';
import comboboxViewer from './comboboxViewer.html';
import comboboxEditor from './comboboxEditor.html';
export default class CustomInlineEditDatatable extends LightningDatatable {
    renderedCallback() {
        super.renderedCallback();
        this.hideRowNumberColumn = true;
    }
    static customTypes = {
        combobox: {
            template: comboboxViewer,
            editTemplate: comboboxEditor,
            typeAttributes: ['options'],
            standardCellLayout: true,
        },
    };
}
