// app/javascript/controllers/shipping_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["country", "shippingMethod", "total"]

  connect() {
    console.log("Shipping controller connected")
    this.updateShippingCost()
  }

  updateShippingCost() {
    const country = this.countryTarget.value
    const method = this.shippingMethodTarget.value

    if (!country || !method) return

    fetch(`/calculate_shipping?country=${country}&method=${method}`)
      .then(response => response.json())
      .then(data => {
        this.totalTarget.textContent = `Total: $${data.total.toFixed(2)}`
      })
      .catch(error => {
        console.error('Error fetching shipping cost:', error)
      })
  }
}
