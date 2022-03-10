source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'acts_as_list'

gem 'apexcharts',
  git: 'https://github.com/vtamara/apexcharts.rb.git', branch: :master

gem 'babel-transpiler'

gem 'bcrypt'

gem "best_in_place", git: "https://github.com/mmotherwell/best_in_place"

gem 'bootsnap', '>=1.1.0', require: false

gem 'cancancan'

gem 'cocoon', git: 'https://github.com/vtamara/cocoon.git', 
  branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails' # CoffeeScript para recuersos .js.coffee y vistas

gem 'color'

gem 'devise' # Autenticación y roles

gem 'devise-i18n'

gem 'hotwire-rails'

gem 'jbuilder' # API JSON facil. Ver: https://github.com/rails/jbuilder

gem 'jsbundling-rails'

gem 'kt-paperclip',                 # Anexos
  git: 'https://github.com/kreeti/kt-paperclip.git'

gem 'libxml-ruby'

gem 'odf-report' # Genera ODT

gem 'nokogiri', '>=1.11.1'

gem 'pg' # Postgresql

gem 'prawn' # Generación de PDF

gem 'prawnto_2',  :require => 'prawnto'

gem 'prawn-table'

gem 'rack'

gem 'rack-cors'

gem 'rails', '~> 7.0'
  #git: 'https://github.com/rails/rails.git', branch: '6-1-stable'

gem 'rails-i18n'

gem 'redcarpet' # Markdown

gem 'rspreadsheet' # Genera ODS

gem 'rubyzip', '>= 2.0'

gem 'sassc-rails' # Hojas de estilo con SCSS

gem 'simple_form' # Formularios simples 

gem 'sprockets-rails'

gem 'stimulus-rails'

gem 'turbo-rails', '~> 1.0'

gem 'twitter_cldr' # ICU con CLDR

gem 'tzinfo' # Zonas horarias

gem 'will_paginate' # Listados en páginas


#####
# Motores que se sobrecargan vistas (a diferencia de las anteriores gemas,
# estas ponerse en orden de apilamiento lógico y no alfabético).

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git', branch: :main
  #path: '../sip'

gem 'mr519_gen', # Motor de gestion de formularios y encuestas
  git: 'https://github.com/pasosdeJesus/mr519_gen.git', branch: :main
  #path: '../mr519_gen'

gem 'heb412_gen',  # Motor de nube y llenado de plantillas
  git: 'https://github.com/pasosdeJesus/heb412_gen.git', branch: :main
  #path: '../heb412_gen'

gem 'sivel2_gen', # Motor para manejo de casos
  git: 'https://github.com/pasosdeJesus/sivel2_gen.git', branch: :main
  #path: '../sivel2_gen'

gem 'apo214', # Motor para manejo de casos
  git: 'https://github.com/pasosdeJesus/apo214.git', branch: :main
  #path: '../apo214'

group  :development, :test do
  gem 'debug' # Depurar

  gem 'colorize' # Colores en terminal

  gem 'dotenv-rails'
end


group :development do
  gem 'erd'

  gem 'puma'

  gem 'rails-erd'

  gem 'redis'

  gem 'spring' # Acelera ejecutando en fondo. 

  gem 'web-console'
end


group :test do
  gem 'cuprite'

  gem 'capybara'

  gem 'selenium-webdriver'

  gem 'simplecov', '<0.18' # Debido a https://github.com/codeclimate/test-reporter/issues/418
end


group :production do
  gem 'unicorn' # Para despliegue
end
