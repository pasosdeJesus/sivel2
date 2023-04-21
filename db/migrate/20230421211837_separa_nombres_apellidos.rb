class SeparaNombresApellidos < ActiveRecord::Migration[7.0]
  def up
    porc = Msip::Persona.where("apellidos IS NULL OR trim(apellidos)=''").
      where("nombres IS NOT NULL AND trim(nombres)<>''")
    if porc.count > 0
      puts "Se encontrarion #{porc.count} personas por cambiar. [Enter] para continuar"
      l= gets
      porc.each do |p|
        a = ""
        n = ""
        if p.nombres == "PERSONA SIN IDENTIFICAR"
          a = "N"
          n = "N"
        else
          menserror = ""
          na = Msip::ImportaHelper.separa_apellidos_nombres(p.nombres, menserror)
          if menserror != ""
            puts "** #{p.id} menserror"
          else
            a = na[0]
            n = na[1]
          end
        end
        if a != '' and n  != ''
          puts "n=#{n}, a=#{a}"
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
