require 'sivel2_gen/version'

Sivel2Gen.setup do |config|
      config.ruta_anexos = "/home/vtamara/comp/rails/sivel2/anexos"
      config.ruta_volcados = "/home/vtamara/comp/rails/sivel2/db"
      # En heroku los anexos son super-temporales
      if ENV["HEROKU_POSTGRESQL_MAUVE_URL"]
        config.ruta_anexos = "#{Rails.root}/tmp/"
      end
      config.titulo = "SIVeL " + Sivel2Gen::VERSION
end
