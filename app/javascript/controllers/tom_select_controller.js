import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    this.tomSelect = new TomSelect(this.element, {
      plugins: {
        clear_button: {
          title: 'Remove selection',
        }
      },
      maxItems: 1,
      persist: false,
      createOnBlur: true,
      create: false,
      placeholder: "Select a user",
      render: {
        option: function(data, escape) {
          return `<div class="py-2 px-3 hover:bg-blue-50">
            <div class="font-medium">${escape(data.text)}</div>
          </div>`
        },
        item: function(data, escape) {
          return `<div class="font-medium">${escape(data.text)}</div>`
        }
      },
      // Add these style-related options
      controlInput: '<input class="ts-input">',
      dropdownClass: 'ts-dropdown',
      optionClass: 'ts-option',
      itemClass: 'ts-item',
      loadingClass: 'ts-loading'
    })
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }
}