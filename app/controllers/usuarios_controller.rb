# encoding: UTF-8

require 'sip/concerns/controllers/usuarios_controller'

class UsuariosController < Heb412Gen::ModelosController
  include Sip::Concerns::Controllers::UsuariosController

  def vistas_manejadas
    ['Usuario']
  end
end
