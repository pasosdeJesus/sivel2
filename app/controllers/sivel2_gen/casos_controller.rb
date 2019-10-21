# frozen_string_literal: true

require 'sivel2_gen/concerns/controllers/casos_controller'

module Sivel2Gen
  class CasosController < Heb412Gen::ModelosController

    include Sivel2Gen::Concerns::Controllers::CasosController

    def campoord_inicial
      'fecha'
    end

    # GET casos/mapa
    def mapaosm
      render 'mapaosm', layout: 'application'
    end
  end
end
