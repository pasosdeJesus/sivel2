require 'apo214/concerns/models/persona'

module Msip
  class Persona < ActiveRecord::Base
    include Apo214::Concerns::Models::Persona
  end
end
