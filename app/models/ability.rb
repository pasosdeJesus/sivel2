# frozen_string_literal: true

class Ability < Sivel2Gen::Ability
  GRUPO_DESAPARICION_CASOS = 25

  def tablasbasicas
    r = (Msip::Ability::BASICAS_PROPIAS -
         [["Msip", "oficina"]]
        ) + Sivel2Gen::Ability::BASICAS_PROPIAS - [
          ["Sivel2Gen", "actividadoficio"],
          ["Sivel2Gen", "escolaridad"],
          ["Sivel2Gen", "estadocivil"],
          ["Sivel2Gen", "maternidad"],
        ]
    r
  end

  # Establece autorizaciones con CanCanCan
  def initialize(usuario = nil)
    initialize_sivel2_gen(usuario)
    can(:contar, Sivel2Gen::Caso)
    if usuario && usuario.rol
      can([:read, :update], Mr519Gen::Encuestausuario)
      if Rails.configuration.x.sivel2_desaparicion &&
          usuario && usuario.grupo.pluck(:id).include?(
            GRUPO_DESAPARICION_CASOS,
          )
        can(:pestanadesaparicion, Sivel2Gen::Caso)
        cannot(:solocambiaretiquetas, Sivel2Gen::Caso)
      end
      case usuario.rol
      when Ability::ROLADMIN
        can(:manage, Mr519Gen::Encuestausuario)
      end
    end
  end
end
