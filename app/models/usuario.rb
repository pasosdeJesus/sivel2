require 'sivel2_gen/concerns/models/usuario'

class Usuario < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Usuario
end
