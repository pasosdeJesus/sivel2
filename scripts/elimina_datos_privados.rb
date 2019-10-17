# Ejecutar con 
# bin/rails runner -e production scripts/elimina_datos_privados.rb 

ActiveRecord::Base.connection.execute <<-SQL
  DELETE FROM sivel2_gen_caso_etiqueta;
  DELETE FROM sip_etiqueta WHERE nombre NOT IN ('AMARILLO',
    'AZUL', 'MES_INEXACTO', 'ROJO', 'VERDE');
  DELETE FROM sivel2_gen_caso_contexto WHERE id_caso IN ( 
    SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  DELETE FROM sivel2_gen_caso_categoria_presponsable WHERE 
    id_caso_presponsable IN ( SELECT id FROM sivel2_gen_caso_presponsable WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_caso_presponsable WHERE id_caso IN ( 
    SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  DELETE FROM sivel2_gen_caso_usuario WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  DELETE FROM sivel2_gen_acto WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  DELETE FROM sivel2_gen_antecedente_victima WHERE 
    id_victima IN (SELECT id from sivel2_gen_victima WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_victima WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  DELETE FROM sivel2_gen_actocolectivo WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  UPDATE sivel2_gen_caso SET ubicacion_id=NULL WHERE fecha <'2001-01-01';
  DELETE FROM sip_ubicacion WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');

  DELETE FROM sivel2_gen_antecedente_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_filiacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_organizacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_profesion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_rangoedad_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_sectorsocia_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_victimacolectiva_vinculoestado WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva WHERE
      id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01'));
  DELETE FROM sivel2_gen_victimacolectiva WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  
  DELETE FROM sivel2_gen_antecedente_caso WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');

  DELETE FROM sivel2_gen_caso_region WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');
  
  DELETE FROM sivel2_gen_caso_frontera WHERE 
    id_caso IN (SELECT id FROM sivel2_gen_caso WHERE fecha <'2001-01-01');

  DELETE FROM sivel2_gen_caso WHERE fecha<'2001-01-01'; 

SQL
