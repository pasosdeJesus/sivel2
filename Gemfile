source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }


gem 'bcrypt'

gem 'bootsnap', '>=1.1.0', require: false

gem 'bootstrap-datepicker-rails'

gem 'cancancan'

gem 'chosen-rails', git: 'https://github.com/vtamara/chosen-rails.git', branch: 'several-fixes'

gem 'cocoon', git: 'https://github.com/vtamara/cocoon.git', branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails' # CoffeeScript para recuersos .js.coffee y vistas

gem 'colorize' # Colores en terminal

gem 'devise' # Autenticación y roles

gem 'devise-i18n'

gem 'font-awesome-rails'

# Motor de nube y plantillas
gem 'heb412_gen', git: 'https://github.com/pasosdeJesus/heb412_gen.git'
#gem 'heb412_gen', path: '../heb412_gen'

gem 'jbuilder' # API JSON facil. Ver: https://github.com/rails/jbuilder

gem 'jquery-rails' # jquery como librería JavaScript

gem 'jquery-ui-rails'

gem 'libxml-ruby'

# Motor de formularios
gem 'mr519_gen', git: 'https://github.com/pasosdeJesus/mr519_gen.git'
# gem 'mr519_gen', path: '../mr519_gen'

gem 'odf-report', git: 'https://github.com/vtamara/odf-report.git', branch: 'rubyzip-1.3' # Genera ODT

gem 'paperclip' # Maneja adjuntos

gem 'pg' # Postgresql

gem 'prawn' # Generación de PDF

gem 'prawnto_2',  :require => 'prawnto'

gem 'prawn-table'

gem 'puma' # Servidor de aplicaciones

gem 'pick-a-color-rails' # Facilita elegir colores en tema

gem 'rails', '~> 6.0.0.rc1'

gem 'rails-i18n'

gem 'redcarpet' # Markdown

gem 'rspreadsheet' # Genera ODS

gem 'rubyzip', '>= 2.0'

gem 'sass-rails' # Hojas de estilo con SCSS

gem 'simple_form' # Formularios simples 

# Motor estilo Pasos de Jesús
gem 'sip', git: 'https://github.com/pasosdeJesus/sip.git'# , branch: :bs4
#gem 'sip', path: '../sip'

# Manejo de casos
gem 'sivel2_gen', git: 'https://github.com/pasosdeJesus/sivel2_gen.git'
#gem 'sivel2_gen', path: '../sivel2_gen'

gem 'tiny-color-rails'

gem 'turbolinks' # Seguir enlaces y redirecciones más rápido. 

gem 'twitter-bootstrap-rails' # Bootstrap y FontAwesome

gem 'twitter_cldr' # ICU con CLDR

gem 'tzinfo' # Zonas horarias

gem 'uglifier' # Uglifier comprime recursos Javascript

gem 'webpacker' # módulos en Javascript https://github.com/rails/webpacker

gem 'will_paginate' # Listados en páginas



group  :development, :test do
 
  #gem 'byebug' # Depurar
  
end


group :development do

  gem 'erd'
  
  gem 'spring' # Acelera ejecutando en fondo. 

  gem 'web-console'

end


group :test do
  gem 'capybara'

  gem 'selenium'

  gem 'selenium-webdriver'

  gem 'simplecov'

end


group :production do
  
  gem 'unicorn' # Para despliegue

end
