// Carga todos los canales de este directorio y sus subdirectorios.
// Los archivos con canales deben ser de la forma  *_channel.js.

const channels = require.context('.', true, /_channel\.js$/)
channels.keys().forEach(channels)
