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