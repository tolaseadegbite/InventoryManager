import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { id: String }

  markRead(event) {
    event.preventDefault()
    const notificationId = this.idValue
    const targetUrl = event.currentTarget.href
    
    // Add debug logging
    console.log('Notification ID:', notificationId)
    
    if (!notificationId) {
      console.error('No notification ID found')
      return
    }

    fetch(`/notifications/${notificationId}/mark_read`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      }
    })
    .then(response => {
      if (response.ok) {
        event.currentTarget.classList.replace('bg-blue-100', 'bg-white')
        window.location.href = targetUrl
      } else {
        console.error('Failed to mark notification as read')
      }
    })
    .catch(error => {
      console.error('Error:', error)
    })
  }
}