class SeparaNombresApellidos < ActiveRecord::Migration[7.0]
  def up
    porc = Sip::Persona.where("apellidos IS NULL OR trim(apellidos)=''").
      where("nombres IS NOT NULL AND trim(nombres)<>''")
    if porc.count > 0
      puts "Se encontrarion #{porc.count} personas por cambiar. [Enter] para continuar"
      l= gets
      porc.each do |p|
        a = ""
        n = ""
        cid = ""
        v = Sivel2Gen::Victima.where(id_persona: p.id)
        if v.count > 0
          cid = v.map(&:id_caso).join(";")
        end
        if p.nombres == "PERSONA SIN IDENTIFICAR"
          a = "N"
          n = "N"
        else
          menserror = ""
          na = Sip::ImportaHelper.separa_apellidos_nombres(p.nombres, menserror)
          if menserror != ""
            puts "#{p.id},#{cid},,,,#{menserror}"
          else
            a = na[0]
            n = na[1]
          end
        end
        if a != '' and n  != ''
          puts "#{p.id},#{cid},#{p.nombres},#{n},#{a},"
          p.nombres = n
          p.apellidos = a
          p.save
        end
      end
    end
  end
  def down
    #raise ActiveRecord::IrreversibleMigration
  end
end
