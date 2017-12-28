class PlantillaEjemplo < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      INSERT INTO heb412_gen_plantillahcm 
        (id, ruta, descripcion, fuente, licencia, vista, nombremenu, filainicial) 
      VALUES
        (1, 'plantillaslistadocasos/ReporteTabla.ods', 
         'Listado genérico de casos', 'Pasos de Jesús',
          'Dominio Público', 'Caso', 'Listado genérico de casos', '5');
      INSERT INTO heb412_gen_campoplantillahcm 
        (plantillahcm_id, nombrecampo, columna) 
        VALUES (1, 'caso_id', 'A');
      INSERT INTO heb412_gen_campoplantillahcm 
        (plantillahcm_id, nombrecampo, columna) 
        VALUES (1, 'fecha', 'B');
      INSERT INTO heb412_gen_campoplantillahcm 
        (plantillahcm_id, nombrecampo, columna) 
        VALUES (1, 'memo', 'C');
      INSERT INTO heb412_gen_campoplantillahcm 
        (plantillahcm_id, nombrecampo, columna) 
        VALUES (1, 'ubicaciones', 'D');
      INSERT INTO heb412_gen_campoplantillahcm 
        (plantillahcm_id, nombrecampo, columna) 
        VALUES (1, 'victimas', 'E');
      INSERT INTO heb412_gen_campoplantillahcm 
        (plantillahcm_id, nombrecampo, columna) 
        VALUES (1, 'presponsables', 'F');
      INSERT INTO heb412_gen_campoplantillahcm 
        (plantillahcm_id, nombrecampo, columna) 
        VALUES (1, 'tipificacion', 'G');
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM heb412_gen_campoplantillahcm WHERE plantillahcm_id IN (SELECT id FROM heb412_gen_plantillahcm WHERE descripcion = 'Listado genérico de casos');
      DELETE FROM heb412_gen_plantillahcm WHERE descripcion = 'Listado genérico de casos' ;
    SQL
  end
end
