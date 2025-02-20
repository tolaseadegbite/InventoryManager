// app/javascript/controllers/category_selector_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selector", "allCheckbox"]

  connect() {
    this.toggleSelector()
  }

  toggleSelector() {
    const isAllSelected = this.allCheckboxTarget.checked
    this.selectorTarget.style.display = isAllSelected ? 'none' : 'block'
  }

  // Called when the checkbox is changed
  toggleVisibility() {
    this.toggleSelector()
  }
}