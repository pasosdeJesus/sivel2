require 'apo214/concerns/models/persona'

module Sip
  class Persona < ActiveRecord::Base
    include Apo214::Concerns::Models::Persona
  end
end
