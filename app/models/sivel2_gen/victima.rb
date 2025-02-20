# frozen_string_literal: true

require "sivel2_gen/concerns/models/victima"

module Sivel2Gen
  class Victima < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Victima

    validate :hijos_valido

    def hijos_valido
      if hijos && (hijos < 0 || hijos > 100)
        errors.add(
          :hijos, "El número de hijos debe estar en blanco o " \
            "ser un número entre 0 y 100"
        )
      end
    end
  end
end
