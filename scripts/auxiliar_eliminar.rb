
def ejecutar_sql(sql)
  puts "+ #{sql}"
  ActiveRecord::Base.connection.execute sql
end


def eliminar_casos(subconsulta_ids_por_eliminar)
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_fuenteprensa WHERE 
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_fotra 
    WHERE id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_anexo_caso WHERE 
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")

  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_etiqueta WHERE 
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_contexto WHERE 
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_categoria_presponsable WHERE 
    id_caso_presponsable IN ( SELECT id FROM 
      sivel2_gen_caso_presponsable WHERE id_caso IN (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_respuestafor WHERE 
    caso_id in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_presponsable WHERE 
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_usuario WHERE 
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_acto WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_antecedente_victima WHERE 
    id_victima IN (SELECT id from sivel2_gen_victima WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_sectorsocialsec_victima WHERE 
    victima_id IN (SELECT id from sivel2_gen_victima WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_contextovictima_victima WHERE 
    victima_id IN (SELECT id from sivel2_gen_victima WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")

  ejecutar_sql("
  DELETE FROM sivel2_gen_victima WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_actocolectivo WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  UPDATE sivel2_gen_caso SET ubicacion_id=NULL WHERE
    id in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM msip_ubicacion WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_antecedente_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE 
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_etnia_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_filiacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_organizacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_profesion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_rangoedad_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_sectorsocial_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_victimacolectiva_vinculoestado WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_victimacolectiva WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_antecedente_caso WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_region WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso_frontera WHERE
    id_caso in (#{subconsulta_ids_por_eliminar});
              ")
  ejecutar_sql("
  DELETE FROM msip_grupoper WHERE 
    id IN (select id_grupoper FROM sivel2_gen_victimacolectiva WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM msip_persona_trelacion
    WHERE persona1 IN (SELECT id_persona FROM sivel2_gen_victima WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM msip_persona_trelacion
    WHERE persona2 IN (SELECT id_persona FROM sivel2_gen_victima WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")

  ejecutar_sql("
  DELETE FROM msip_persona WHERE
    id IN (SELECT id_persona FROM sivel2_gen_victima WHERE
      id_caso in (#{subconsulta_ids_por_eliminar}));
              ")
  ejecutar_sql("
  DELETE FROM sivel2_gen_caso WHERE id IN (#{subconsulta_ids_por_eliminar});
              ")
end
