// app/javascript/controllers/tom_select_multiple_controller.js
import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    this.tomSelect = new TomSelect(this.element, {
      plugins: {
        clear_button: {
          title: 'Remove all',
        },
        remove_button: {
          title: 'Remove this item',
        }
      },
      maxItems: null, // Allow multiple selections
      persist: false,
      createOnBlur: true,
      create: false,
      render: {
        option: function(data, escape) {
          return `<div class="py-2 px-3">${escape(data.text)}</div>`
        },
        item: function(data, escape) {
          return `<div>${escape(data.text)}</div>`
        }
      },
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