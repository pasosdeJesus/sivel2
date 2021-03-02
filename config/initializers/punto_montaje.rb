Sivel2::Application.config.relative_url_root = ENV.fetch(
  'RUTA_RELATIVA', '/sivel2')
Sivel2::Application.config.assets.prefix = ENV.fetch(
  'RUTA_RELATIVA', '/sivel2') == '/' ? 
 '/assets' : (ENV.fetch('RUTA_RELATIVA', '/sivel2') + '/assets')
