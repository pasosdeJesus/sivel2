# encoding: UTF-8
class Ability  < Sivel2Gen::Ability
  def organizacion_responable 
    'Mi organización'
  end

  def derechos 
    'Terminos'
  end

  def tablasbasicas 
    Sip::Ability::BASICAS_PROPIAS + 
      Sivel2Gen::Ability::BASICAS_PROPIAS - [
        ['Sivel2Gen', 'actividadoficio'],
        ['Sivel2Gen', 'escolaridad'],
        ['Sivel2Gen', 'estadocivil'],
        ['Sivel2Gen', 'maternidad']
      ]
  end

  # Establece autorizaciones con CanCanCan
  def initialize(usuario = nil)
    # Sin autenticación puede consultarse información geográfica 
    can :read, [Sip::Pais, Sip::Departamento, Sip::Municipio, Sip::Clase]
    if !usuario || usuario.fechadeshabilitacion
      return
    end
    can :contar, Sip::Ubicacion
    can :contar, Sivel2Gen::Caso
    can :buscar, Sivel2Gen::Caso
    can :lista, Sivel2Gen::Caso
    can :descarga_anexo, Sip::Anexo
    can :nuevo, Sip::Ubicacion
    can :nuevo, Sivel2Gen::Presponsable
    can :nuevo, Sivel2Gen::Victima
    can :nuevo, Sivel2Gen::Victimacolectiva
    can :nuevo, Sivel2Gen::Combatiente
    if usuario && usuario.rol then
      case usuario.rol 
      when Ability::ROLANALI
        can :read, Sivel2Gen::Caso
        can :new, Sivel2Gen::Caso
        can [:update, :create, :destroy], Sivel2Gen::Caso
        can :manage, Sip::Persona
        can :manage, Sivel2Gen::Acto
        can :manage, Sivel2Gen::Actocolectivo
        can :read, Heb412Gen::Doc
      when Ability::ROLADMIN
        can :manage, Sivel2Gen::Caso
        can :manage, Sip::Persona
        can :manage, Usuario
        can :manage, Sivel2Gen::Acto
        can :manage, Sivel2Gen::Actocolectivo
        can :manage, Heb412Gen::Doc
        can :manage, Sip::Respaldo7z
        can :manage, :tablasbasicas
        tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can :manage, c
        end
      end
    end
  end
end

