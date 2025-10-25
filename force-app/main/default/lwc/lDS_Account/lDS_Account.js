/**
 * This is the component's JavaScript controller file.
 * It handles the logic and events.
 */
import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// 1. Import the Custom Label
// We give it a friendly name 'successMessage' to use in our code.
// You must create this Custom Label in Salesforce Setup.
// See the 'CustomLabelSetup.md' file for instructions.
import successMessage from "@salesforce/label/c.Record_Save_Success";

export default class SimpleLdsForm extends LightningElement {
  /**
   * This function is called when the 'onsuccess' event fires
   * from the lightning-record-edit-form.
   *
   * @param {Event} event - The success event, which contains record details.
   */
  handleSuccess(event) {
    // The event.detail.id contains the ID of the newly created record
    console.log("Record created with ID:", event.detail.id);

    // 2. Create the Toast "pop-up" message
    const toastEvent = new ShowToastEvent({
      title: "Success!",
      // 3. Use the imported Custom Label as the message
      message: successMessage,
      variant: "success", // This shows a green success toast
    });

    // 4. Dispatch the event to show the toast
    this.dispatchEvent(toastEvent);

    // The lightning-record-edit-form automatically resets itself
    // after a successful save, so we don't need to do it manually.
  }
}
