import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]
  
  connect() {
    this.refreshInterval = setInterval(() => {
      this.refresh()
    }, 30000) // Refresh every 30 seconds
  }
  
  disconnect() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }
  }
  
  refresh() {
    this.element.requestSubmit()
  }
}