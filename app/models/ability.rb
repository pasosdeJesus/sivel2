# encoding: UTF-8
class Ability  < Sivel2Gen::Ability

  # Establece autorizaciones con CanCanCan
  def initialize(usuario = nil)
    initialize_sivel2_gen(usuario)
  end

end

