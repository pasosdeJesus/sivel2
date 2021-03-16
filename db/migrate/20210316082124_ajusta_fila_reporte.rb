class AjustaFilaReporte < ActiveRecord::Migration[6.1]

  def cambia_dato(tabla, columna, opciones)
    w = ''
    if opciones[:donde]
      w = " AND #{opciones[:donde]}"
    end
    execute <<-SQL
      UPDATE #{tabla} SET #{columna}=#{opciones[:a]}
        WHERE #{columna}=#{opciones[:de]}
        #{w}
    SQL
  end

  def change
    reversible do |dir|
      dir.up {
        cambia_dato :heb412_gen_plantillahcm, :filainicial, de: 5, a: 6,
          donde: "ruta='plantilla/ReporteTabla.ods'"
      }
      dir.down {
        cambia_dato :heb412_gen_plantillahcm, :filainicial, de: 6, a: 5,
          donde: "ruta='plantilla/ReporteTabla.ods'"
      }
    end
  end

#  def down
#    cambia_dato :heb412_gen_plantillahcm, :filainicial, 6, 5,
#      "ruta='plantilla/ReporteTabla.ods'"
#  end

end
