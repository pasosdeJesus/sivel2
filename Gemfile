source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

# Rails con internacionalización
gem 'rails', '~> 6.0.0.rc1'
gem 'rails-i18n'

# Postgresql
gem 'pg'#, '~> 0.21'

# Servidor de aplicaciones
gem 'puma'

# Colores en terminal
gem 'colorize'

# Hojas de estilo con SCSS
gem 'sass-rails'

# posibilidad de manejar módulos en Javascript https://github.com/rails/webpacker
gem 'webpacker'

# Seguir enlaces y redirecciones más rápido. Ver: https://github.com/rails/turbolinks
gem 'turbolinks'

# API JSON facil. Ver: https://github.com/rails/jbuilder
gem 'jbuilder'

gem 'bootsnap', '>=1.1.0', require: false

# Bootstrap y FontAwesome
gem 'twitter-bootstrap-rails'
gem 'font-awesome-rails'
gem 'bootstrap-datepicker-rails'


# CoffeeScript para recuersos .js.coffee y vistas
gem 'coffee-rails'

# Uglifier comprime recursos Javascript
gem 'uglifier'

gem 'chosen-rails', git: 'https://github.com/vtamara/chosen-rails.git', branch: 'several-fixes'

# jquery como librería JavaScript
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'odf-report'
gem 'redcarpet'
gem 'libxml-ruby'#
gem 'rspreadsheet'


# Formularios simples 
gem 'simple_form'

# Formularios anidados (algunos con ajax)
gem 'cocoon', git: 'https://github.com/vtamara/cocoon.git', branch: 'new_id_with_ajax'
#gem 'cocoon', path: '../cocoon'

# Autenticación y roles
gem 'devise'
gem 'devise-i18n'
gem 'cancancan'
gem 'bcrypt'

# Listados en páginas
gem 'will_paginate'

# ICU con CLDR
gem 'twitter_cldr'

# Maneja adjuntos
gem 'paperclip'

# Generación de PDF
gem 'prawn'
gem 'prawnto_2',  :require => 'prawnto'
gem 'prawn-table'


# Zonas horarias
gem 'tzinfo'

# Motor estilo Pasos de Jesús
gem 'sip', git: 'https://github.com/pasosdeJesus/sip.git'
#gem 'sip', path: '../sip'

# Motor de nube y plantillas
gem 'heb412_gen', git: 'https://github.com/pasosdeJesus/heb412_gen.git'
#gem 'heb412_gen', path: '../heb412_gen'

# Manejo de casos
gem 'sivel2_gen', git: 'https://github.com/pasosdeJesus/sivel2_gen.git'
#gem 'sivel2_gen', path: '../sivel2_gen'


group  :development, :test do
  # Depurar
  #gem 'byebug', platforms [:mri, :mingw, :x64_mingw]
end


# Los siguientes son para desarrollo o para pruebas con generadores
group :development do
  # Consola irb en páginas con excepciones o usando <%= console %> en vistas
  gem 'web-console'
  gem 'erd'
  # Acelera ejecutando en fondo. https://github.com/jonleighton/spring
  gem 'spring'

end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'selenium'
  gem 'selenium-webdriver'
  gem 'simplecov'
  #gem 'connection_pool'
  #gem 'minitest-reporters'
  #gem 'rails-controller-testing'

  # Un proceso para cada prueba -- acelera
  #gem 'spork'

  # Para examinar errores, usar 'rescue '
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end


group :production do
  # Para despliegue
  gem 'unicorn' #, '~> 5.5.0.1.g6836'

  # Requerido por heroku para usar stdout como bitacora
  gem 'rails_12factor'
end
