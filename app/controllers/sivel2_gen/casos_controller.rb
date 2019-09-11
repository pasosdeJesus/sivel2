
# encoding: UTF-8

require 'sivel2_gen/concerns/controllers/casos_controller'

module Sivel2Gen
  class CasosController < Heb412Gen::ModelosController 

    include Sivel2Gen::Concerns::Controllers::CasosController

          # GET casos/mapa
          def mapaosm
            render 'mapaosm', layout: 'application'
          end
  end
end
