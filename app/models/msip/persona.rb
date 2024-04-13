require 'sivel2_gen/concerns/models/persona'

module Msip
  class Persona < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Persona
  end
end
