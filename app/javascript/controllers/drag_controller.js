// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "@hotwired/stimulus"
import { Sortable } from "sortablejs"
import Rails from "@rails/ujs"

export default class extends Controller {
  connect() {
    console.log("conectado a stimulus actualizando posicion")
    this.sortable = Sortable.create(this.element, {
      onEnd: this.end.bind(this)
    })
  }
  end(event) {
    let id = event.item.dataset.id
    let data = new FormData()
    data.append("posicion", event.newIndex + 1)
    Rails.ajax({
      url: this.data.get("url").replace(":id", id),
      type: 'PATCH',
      data: data
    }
    )
  }
}
