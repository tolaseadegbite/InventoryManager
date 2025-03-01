// import { Controller } from "@hotwired/stimulus"

// export default class extends Controller {
//   static targets = ["list"]
  
//   connect() {
//     // Only set up auto-refresh on the dashboard
//     if (window.location.pathname.includes('/dashboard')) {
//       this.refreshInterval = setInterval(() => {
//         this.refresh()
//       }, 30000) // Refresh every 30 seconds
//     }
//   }
  
//   disconnect() {
//     if (this.refreshInterval) {
//       clearInterval(this.refreshInterval)
//     }
//   }
  
//   refresh() {
//     const url = new URL(window.location.href)
//     url.searchParams.set('_', new Date().getTime())
    
//     fetch(url, {
//       headers: {
//         Accept: "text/vnd.turbo-stream.html"
//       }
//     })
//   }
// }

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filters"]
  
  toggleFilters() {
    this.filtersTarget.classList.toggle("hidden")
  }
  
  resetForm(event) {
    event.preventDefault()
    const form = event.target.closest('form')
    
    // Reset all tom-select instances in the form
    document.querySelectorAll('[data-controller="tom-select"]').forEach(select => {
      if (select.tomSelect) {
        select.tomSelect.clear()
      }
    })
    
    // Reset the standard form fields
    form.reset()
    
    // Submit the form
    form.requestSubmit()
  }
}