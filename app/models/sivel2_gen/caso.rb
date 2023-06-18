
require 'sivel2_gen/concerns/models/caso'

module Sivel2Gen 
  class Caso < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Caso

    has_many :victima,  foreign_key: "caso_id", dependent: :destroy, 
      class_name: 'Sivel2Gen::Victima', validate: true
  end
end
