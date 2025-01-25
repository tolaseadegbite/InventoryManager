// app/javascript/controllers/clear_form_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];

  clear(event) {
    event.preventDefault(); // Prevent the default link behavior

    // Manually clear each form field
    this.clearFormFields();

    // Submit the form programmatically
    this.submitForm();
  }

  clearFormFields() {
    // Get all input, select, and textarea elements within the form
    const fields = this.formTarget.querySelectorAll("input, select, textarea");

    fields.forEach((field) => {
      if (field.type === "checkbox" || field.type === "radio") {
        // Uncheck checkboxes and radio buttons
        field.checked = false;
      } else if (field.tagName === "SELECT") {
        // Reset select elements to their first option
        field.selectedIndex = 0;
      } else {
        // Clear text inputs, date inputs, number inputs, etc.
        field.value = "";
      }
    });
  }

  submitForm() {
    // Submit the form programmatically
    this.formTarget.dispatchEvent(new Event("submit", { bubbles: true }));
  }
}