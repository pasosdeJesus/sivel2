# Usa el de sip que prepara node_modules
# E incluye:
# - fuentes de fontawesome
# - icono de chosen-js
#

Rails.application.config.assets.paths << Rails.root.join('node_modules/@pasosdejesus/mapa_tiempo_yi_liu/')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( dist/index.bundle.js dist/index.bundle.js.map )
