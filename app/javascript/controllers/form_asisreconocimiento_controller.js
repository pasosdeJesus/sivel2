import { Controller } from "@hotwired/stimulus"
import { Turbo, cable } from "@hotwired/turbo-rails"

export default class extends Controller {
  connect() {
    console.log('stimulus conectado a form de asisreconocimiento apo214');
  }
  reset() {
    this.element.reset()
  }
}
