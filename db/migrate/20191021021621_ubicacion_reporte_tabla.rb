class UbicacionReporteTabla < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      UPDATE heb412_gen_plantillahcm SET ruta='plantillas/ReporteTabla.ods' where ruta='plantillaslistadocasos/ReporteTabla.ods';
    SQL
  end

  def down
    execute <<-SQL
      UPDATE heb412_gen_plantillahcm SET ruta='plantillaslistadocasos/ReporteTabla.ods' where ruta='plantillas/ReporteTabla.ods';
    SQL
  end
end
