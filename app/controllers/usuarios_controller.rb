# encoding: UTF-8

require 'sip/concerns/controllers/usuarios_controller'

class UsuariosController < Heb412Gen::ModelosController
  include Sip::Concerns::Controllers::UsuariosController

  def vistas_manejadas
    ['Usuario']
  end

  def atributos_index
    r = [ 
      :id,
      :nusuario,
      :nombre,
      :descripcion,
      :rol
    ]
    if can?(:manage, Sip::Grupo)
      r += [:sip_grupo]
    end
    r += [ 
      :email,
      :tema,
      :created_at_localizada,
      :habilitado
    ]
    r
  end

  def atributos_form
    r = [ 
      :nusuario,
      :nombre,
      :descripcion,
      :rol
    ]
    if can?(:manage, Sip::Grupo)
      r += [:sip_grupo]
    end
    r += [
      :email,
      :tema,
      :idioma,
      :encrypted_password,
      :fechacreacion_localizada,
      :fechadeshabilitacion_localizada,
      :failed_attempts,
      :unlock_token,
      :locked_at
    ]
  end

end

