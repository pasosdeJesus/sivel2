// Mapa con casos e indicadores, fuentes de Covid19.health

import React from 'react'
import ReactDOM from 'react-dom'
import { render } from 'react-dom'

import MapaTiempo from '@pasosdejesus/mapa_tiempo_yi_liu'

render(<MapaTiempo casos_url='https://base.nocheyniebla.org/casos/cuenta' usar_proxy_cors='false' />, document.getElementById('root'))


