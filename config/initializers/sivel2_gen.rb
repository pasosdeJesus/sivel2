Sivel2Gen.setup do |config|
      config.ruta_anexos = "/var/www/resbase/anexos"
      config.ruta_volcados = "/var/www/resbase/sivel2_sjrven/"
      # En heroku los anexos son super-temporales
      if !ENV["HEROKU_POSTGRESQL_MAUVE_URL"].nil?
        Sivel2Gen.config.ruta_anexos = "#{Rails.root}/tmp/"
      end
      config.titulo = "SIVeL " + Sivel2Gen::VERSION
end
