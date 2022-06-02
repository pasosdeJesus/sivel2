import { Controller } from "@hotwired/stimulus"
import consumer from '../../javascript/channels/consumer';

export default class extends Controller {

    connect() {

      console.log("Crearemos una subscripción para el canal 'AsisreconocimientoChannel', asisreconocimiento_id: %s", this.data.get('asisreconocimientoid'));
     this.channel = consumer.subscriptions.create({ channel: 'AsisreconocimientoChannel', asisreconocimiento_id: this.data.get('asisreconocimientoid') }, {
            connected: this._cableConnected.bind(this),
            disconnected: this._cableDisconnected.bind(this),
            received: this._cableReceived.bind(this),
          });
      jQuery(".best_in_place").best_in_place(); 
    }

    _cableConnected() {
        console.log('_cableConnected');
    }

    _cableDisconnected() {
        console.log('_cableDisconnected');
    }

    _cableReceived(data) {
        console.log('_cableReceived');
        console.log(data.mensaje);

       //this.asisestadoTarget.innerHTML = data.mensaje;
    }
}
