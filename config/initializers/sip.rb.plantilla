require 'sivel2_gen/version'

Sip.setup do |config|
      config.ruta_anexos = "/var/www/htdocs/sivel2/anexos"
      config.ruta_volcados = "/var/www/htdocs/sivel2/bd"
      # En heroku los anexos son super-temporales
      if ENV["HEROKU_POSTGRESQL_MAUVE_URL"]
        config.ruta_anexos = "#{Rails.root}/tmp/"
      end
      config.titulo = "SIVeL " + Sivel2Gen::VERSION
end
