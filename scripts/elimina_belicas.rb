# Ejecutar con 
# bin/rails runner -e development scripts/elimina_belicas.rb 

require_relative 'auxiliar_eliminar'

lb = ActiveRecord::Base.connection.execute <<-SQL
  DROP VIEW IF EXISTS belicas;
  CREATE VIEW belicas AS (
    SELECT DISTINCT cp.id_caso
    FROM sivel2_gen_caso_categoria_presponsable AS ccp
    JOIN sivel2_gen_caso_presponsable AS cp ON cp.id=ccp.id_caso_presponsable
    WHERE ccp.id_categoria IN (
      SELECT c.id FROM sivel2_gen_categoria AS c 
      JOIN sivel2_gen_supracategoria AS s ON s.id=c.supracategoria_id 
      WHERE id_tviolencia='C'
    )
    ORDER BY 1
  );
  -- No podemos usar eliminar_casos("SELECT id_caso FROM belicas")
  -- porque esa funciona elimina antes sivel2_gen_caso_categoria_presponsable
  -- que deja vacía la consulta belicas
  SELECT id_caso FROM belicas;
SQL

lpore = lb.pluck('id_caso')
eliminar_casos(
  "SELECT id FROM sivel2_gen_caso WHERE id IN (#{lpore.join(', ')})"
)
