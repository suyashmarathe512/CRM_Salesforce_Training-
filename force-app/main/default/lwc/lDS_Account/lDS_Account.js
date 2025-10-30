import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import successMessage from "@salesforce/label/c.Record_Save_Success";
export default class SimpleLdsForm extends LightningElement {
  handleSuccess(event) {
    console.log("Record created with ID:", event.detail.id);
    const toastEvent = new ShowToastEvent({
      title: "Success!",
      message: successMessage,
      variant: "success",
    });
    this.dispatchEvent(toastEvent);
  }
}
