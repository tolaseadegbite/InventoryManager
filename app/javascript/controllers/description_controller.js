import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="description"
export default class extends Controller {
  static targets = ["notesField", "toggleLink"];

  toggle(event) {
    event.preventDefault(); // Prevent default link behavior

    const isHidden = this.notesFieldTarget.classList.toggle("hidden");
    this.toggleLinkTarget.textContent = isHidden
      ? "Click to add description"
      : "Click to hide description"; // Update link text
  }
}
