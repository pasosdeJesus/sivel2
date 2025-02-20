# frozen_string_literal: true

class SeparaNombresApellidos < ActiveRecord::Migration[7.0]
  def up
    porc = Msip::Persona.where("apellidos IS NULL OR trim(apellidos)=''")
      .where("nombres IS NOT NULL AND trim(nombres)<>''")
    if porc.count > 0
      puts "Se encontrarion #{porc.count} personas por cambiar. [Enter] para continuar"
      gets
      puts "casos, id_persona, nombre_anterior, nombres, apellidos, observaciones"
      porc.each do |p|
        v = Sivel2Gen::Victima.where(persona_id: p)
        numcasos = v.pluck(:caso_id)

        a = ""
        n = ""
        nombreant = p.nombres
        menserror = ""
        if p.nombres == "PERSONA SIN IDENTIFICAR"
          a = "N"
          n = "N"
        else
          na = Msip::ImportaHelper.separa_apellidos_nombres(p.nombres, menserror)
          if menserror != ""
            puts "** #{p.id} menserror"
          else
            a = na[0]
            n = na[1]
          end
        end
        next unless a != "" and n != ""

        p.nombres = n
        p.apellidos = a
        p.save
        puts "#{numcasos.join(";")}, #{p.id}, #{nombreant}, #{n}, #{a}, #{menserror}"
      end
    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
