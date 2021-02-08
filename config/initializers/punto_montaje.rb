Sivel2::Application.config.relative_url_root = ENV.fetch(
  'RUTA_RELATIVA', '/sivel2')
Sivel2::Application.config.assets.prefix = ENV.fetch(
<<<<<<< HEAD
  'RUTA_RELATIVA', '/sivel2') == '/' ? 
 '/assets' : (ENV.fetch('RUTA_RELATIVA', '/sivel2') + '/assets')
=======
  'RUTA_RELATIVA', '/sivel2') + '/assets'
>>>>>>> 7f25bc4 (sigue convenciones de sip 2.0b11, ver https://github.com/pasosdeJesus/sip/wiki/2021_2-Actualizaci%C3%B3n-de-sip-2.0b10-a-2.0b11)
