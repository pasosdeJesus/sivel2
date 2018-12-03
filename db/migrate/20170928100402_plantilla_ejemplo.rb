class PlantillaEjemplo < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      UPDATE heb412_gen_campoplantillahcm SET id=id+1000 WHERE id<1000;
      INSERT INTO heb412_gen_plantillahcm (id, ruta, descripcion, fuente,
        licencia, vista, nombremenu, filainicial) 
        (SELECT id+100, ruta, descripcion, fuente, 
          licencia, vista, nombremenu, filainicial FROM heb412_gen_plantillahcm
          WHERE id<100
        );
      UPDATE heb412_gen_campoplantillahcm SET 
        plantillahcm_id=plantillahcm_id+100 WHERE plantillahcm_id<100;
      DELETE FROM heb412_gen_plantillahcm WHERE id<100;

      SELECT setval('heb412_gen_campoplantillahcm_id_seq', MAX(id))
        FROM (SELECT 1000 as id UNION 
            SELECT MAX(id) FROM heb412_gen_campoplantillahcm) AS s;
      SELECT setval('heb412_gen_plantillahcm_id_seq', MAX(id), true)
        FROM (SELECT 100 as id UNION 
            SELECT MAX(id) FROM heb412_gen_plantillahcm) AS s;


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
