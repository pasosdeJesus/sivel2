// Recarga viva (live reloading) durante desarrollo
// Recompila automáticamente ante cambios en javascript de app/javascript
// y refresca automáticamente en navegador
// Basado en https://www.colby.so/posts/live-reloading-with-esbuild-and-rails

const path = require('path')
const http = require('http')

const watch = process.argv.includes('--watch')
const clients = []

const watchOptions = {
  onRebuild: (error, result) => {
    if (error) {
      console.error('Falló construcción:', error)
    } else {
      console.log('Construcción exitosa')
      clients.forEach((res) => res.write('data: update\n\n'))
      clients.length = 0
    }
  }
}

require("esbuild").build({
  entryPoints: ["application.js"],
  bundle: true,
  preserveSymlinks: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  watch: watch && watchOptions,
  banner: {
    js: ` (() => new EventSource("http://${process.env.MAQRECVIVA}:${process.env.PUERTORECVIVA}").onmessage = () => location.reload())();`,
  },
}).catch(() => process.exit(1));

http.createServer((req, res) => {
  return clients.push(
    res.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Access-Control-Allow-Origin": "*",
      Connection: "keep-alive",
    }),
  );
}).listen(process.env.PUERTORECVIVA, process.env.IPDES);

