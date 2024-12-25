// app/javascript/controllers/index.js
import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import ShippingController from "./shipping_controller"

// Register shipping controller
application.register("shipping", ShippingController)

// Eager load all other controllers
eagerLoadControllersFrom("controllers", application)
