class Ability  < Apo214::Ability


  GRUPO_DESAPARICION_CASOS = 25


  def tablasbasicas
    r = (Sip::Ability::BASICAS_PROPIAS - 
         [['Sip', 'oficina']]
        ) + Sivel2Gen::Ability::BASICAS_PROPIAS - [
          ['Sivel2Gen', 'actividadoficio'],
          ['Sivel2Gen', 'escolaridad'],
          ['Sivel2Gen', 'estadocivil'],
          ['Sivel2Gen', 'maternidad']
        ] + Apo214::Ability::BASICAS_PROPIAS
    return r
  end

  # Establece autorizaciones con CanCanCan
  def initialize(usuario = nil)
    initialize_sivel2_gen(usuario)
    initialize_apo214(usuario)
    can :contar, Sivel2Gen::Caso
    if usuario && usuario.rol then
      can [:read, :update], Mr519Gen::Encuestausuario
      if usuario && usuario.sip_grupo.pluck(:id).include?(
          GRUPO_DESAPARICION_CASOS)
        can :pestanadesaparicion, Sivel2Gen::Caso
        cannot :solocambiaretiquetas, Sivel2Gen::Caso
      end
      case usuario.rol
      when Ability::ROLADMIN
        can :manage, Mr519Gen::Encuestausuario
      end
    end
  end

end

