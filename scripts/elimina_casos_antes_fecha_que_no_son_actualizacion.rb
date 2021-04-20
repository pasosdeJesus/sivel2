# Ejecutar con 
# bin/rails runner -e development scripts/elimina_casos_antes_fecha_que_no_son_actualizacion

puts ARGV
fechaini = ARGV[0]
if fechaini.nil? 
  puts "Primer parametro debe ser fecha hasta la cual eliminar y no '#{fechaini}'"
  exit 1
end
fechaini = Sip::FormatoFechaHelper.reconoce_adivinando_locale(fechaini)

ids_por_eliminar = "SELECT id FROM sivel2_gen_caso WHERE fecha<='#{fechaini}'
    AND id NOT IN (SELECT DISTINCT id_caso FROM sivel2_gen_caso_etiqueta 
      WHERE id_etiqueta IN (SELECT id FROM sip_etiqueta 
        WHERE (nombre LIKE '%01%' or nombre like '%02%') 
        AND NOT NOMBRE LIKE '%20%'
      )
    )"

;
def ejecuta_sql(sql)
  puts "+ #{sql}"
  ActiveRecord::Base.connection.execute sql
end

ejecuta_sql("
  DELETE FROM sivel2_gen_caso_fotra WHERE anexo_caso_id IN
    (SELECT id FROM sivel2_gen_anexo_caso WHERE 
    id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_anexo_caso WHERE 
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_etiqueta WHERE 
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_contexto WHERE 
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_categoria_presponsable WHERE 
    id_caso_presponsable IN ( SELECT id FROM 
      sivel2_gen_caso_presponsable WHERE id_caso IN (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_respuestafor WHERE 
    caso_id in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_presponsable WHERE 
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_usuario WHERE 
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_acto WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_antecedente_victima WHERE 
    id_victima IN (SELECT id from sivel2_gen_victima WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_victima WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_actocolectivo WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  UPDATE sivel2_gen_caso SET ubicacion_id=NULL WHERE
    fecha<='#{fechaini}';
    ")
ejecuta_sql("
  DELETE FROM sip_ubicacion WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_antecedente_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE 
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_filiacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_organizacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_profesion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_rangoedad_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_sectorsocial_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_victimacolectiva_vinculoestado WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_victimacolectiva WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_antecedente_caso WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_region WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_frontera WHERE
    id_caso in (#{ids_por_eliminar});
    ")
ejecuta_sql("
  DELETE FROM sip_grupoper WHERE 
    id IN (select id_grupoper FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sip_persona_trelacion
    WHERE persona1 IN (SELECT id_persona FROM sivel2_gen_victima WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sip_persona_trelacion
    WHERE persona2 IN (SELECT id_persona FROM sivel2_gen_victima WHERE
      id_caso in (#{ids_por_eliminar}));
    ")

ejecuta_sql("
  DELETE FROM sip_persona WHERE
    id IN (SELECT id_persona FROM sivel2_gen_victima WHERE
      id_caso in (#{ids_por_eliminar}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso WHERE id IN (#{ids_por_eliminar});
    ")

