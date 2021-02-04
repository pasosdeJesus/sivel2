Sivel2::Application.config.relative_url_root = 
  (ENV['RUTA_RELATIVA'] || '/sivel2')
Sivel2::Application.config.assets.prefix = 
  (ENV['RUTA_RELATIVA'] || '/sivel2') + '/assets'
