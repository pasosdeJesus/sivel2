# frozen_string_literal: true

# Ejecutar con
# bin/rails runner -e development scripts/elimina_belicas.rb

ActiveRecord::Base.connection.execute(<<-SQL)
  DELETE FROM sivel2_gen_antecedente_combatiente;
  DELETE FROM combatiente_presponsable;
  DELETE FROM combatiente;
  DELETE FROM sivel2_gen_caso_categoria_presponsable WHERE categoria_id IN#{" "}
    (SELECT c.id FROM  sivel2_gen_categoria AS c JOIN#{" "}
    sivel2_gen_supracategoria AS s ON c.supracategoria_id=s.id WHERE#{" "}
    tviolencia_id='C');
  DELETE FROM sivel2_gen_actocolectivo WHERE categoria_id IN (SELECT c.id#{" "}
    FROM  sivel2_gen_categoria AS c JOIN sivel2_gen_supracategoria AS s ON#{" "}
    c.supracategoria_id=s.id WHERE tviolencia_id='C');
  DELETE FROM sivel2_gen_acto WHERE categoria_id IN (SELECT c.id#{" "}
    FROM  sivel2_gen_categoria AS c JOIN sivel2_gen_supracategoria AS s ON#{" "}
    c.supracategoria_id=s.id WHERE tviolencia_id='C');
	DROP VIEW IF EXISTS nobelicas;
	CREATE VIEW nobelicas AS (SELECT caso_id FROM sivel2_gen_acto) UNION#{" "}
    (SELECT caso_id FROM sivel2_gen_actocolectivo) UNION#{" "}
    (SELECT caso_presponsable_id/10000 FROM sivel2_gen_caso_categoria_presponsable) ORDER BY 1;

  DELETE FROM sivel2_gen_caso_categoria_presponsable WHERE#{" "}
    caso_presponsable_id IN#{" "}
      (SELECT DISTINCT id from sivel2_gen_caso_presponsable WHERE
      caso_id NOT IN (SELECT caso_id FROM nobelicas ORDER BY 1));
  UPDATE sivel2_gen_caso SET ubicacion_id=NULL WHERE
    id NOT IN (SELECT DISTINCT caso_id FROM nobelicas ORDER BY 1);
  DELETE FROM sivel2_gen_antecedente_victima WHERE
    victima_id IN (SELECT id FROM sivel2_gen_victima WHERE
      caso_id NOT IN (SELECT DISTINCT caso_id FROM nobelicas ORDER BY 1));
SQL
puts ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM nobelicas")

[
  "sivel2_gen_victimacolectiva_vinculoestado",
  "sivel2_gen_antecedente_victimacolectiva",
  "sivel2_gen_profesion_victimacolectiva",
  "sivel2_gen_etnia_victimacolectiva",
  "sivel2_gen_filiacion_victimacolectiva",
  "sivel2_gen_organizacion_victimacolectiva",
  "sivel2_gen_rangoedad_victimacolectiva",
  "sivel2_gen_sectorsocial_victimacolectiva",
].each do |nt|
  ActiveRecord::Base.connection.execute(
    "DELETE FROM #{nt} WHERE victimacolectiva_id IN
      (SELECT id FROM sivel2_gen_victimacolectiva WHERE
        caso_id NOT IN
        (SELECT DISTINCT caso_id FROM nobelicas ORDER BY 1))",
  )
end

[
  "sivel2_gen_caso_contexto",
  "sivel2_gen_caso_presponsable",
  "sivel2_gen_antecedente_caso",
  "msip_ubicacion",
  "sivel2_gen_caso_usuario",
  "sivel2_gen_acto",
  "sivel2_gen_victima",
  "sivel2_gen_caso_region",
  "sivel2_gen_caso_frontera",
  "sivel2_gen_actocolectivo",
  "sivel2_gen_victimacolectiva",
  "sivel2_gen_caso_etiqueta",
  "sivel2_gen_caso_fuenteprensa",
  "sivel2_gen_caso_fotra",
  "sivel2_gen_anexo_caso",
].each do |nt|
  puts nt
  ActiveRecord::Base.connection.execute(
    "DELETE FROM #{nt} WHERE caso_id NOT IN " \
      "(SELECT DISTINCT caso_id FROM nobelicas ORDER BY 1);",
  )
end
ActiveRecord::Base.connection.execute(
  "DELETE FROM sivel2_gen_caso_respuestafor WHERE caso_id NOT IN " \
    "(SELECT DISTINCT caso_id FROM nobelicas ORDER BY 1);",
)
ActiveRecord::Base.connection.execute(
  "DELETE FROM sivel2_gen_caso WHERE id NOT IN " \
    "(SELECT DISTINCT caso_id FROM nobelicas ORDER BY 1);",
)
ActiveRecord::Base.connection.execute(
  "DELETE FROM msip_anexo WHERE id NOT IN " \
    "(SELECT DISTINCT anexo_id FROM sivel2_gen_anexo_caso);",
)
