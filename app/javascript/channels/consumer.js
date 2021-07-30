// ActionCable provee el marco de trabajo para manejar WebSockets en Rails.
// Puede generar nuevos canales donde viven las características de WebSocket usando la orden `bin/rails generate channel`

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
