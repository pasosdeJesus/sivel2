# Ejecutar con 
#bin/rails runner -e development scripts/deja_solo_rango_casos.rb 1 1000000

puts ARGV
idini = ARGV[0]
if idini.nil? || idini.to_i <= 0
  puts "Primer parametro debe ser caso inicial y no '#{idini}'"
  exit 1
end
idini = idini.to_i

idfin = ARGV[1] 
if idfin.nil? || idfin.to_i <= 0
  puts "Segundo parametro debe ser caso final y no '#{idfin}'"
  exit 1
end
idfin = idfin.to_i

if idini > idfin
  puts "Primero parámetro debe ser menor que segundo"
  exit 1;
end

def ejecuta_sql(sql)
  puts "+ #{sql}"
  ActiveRecord::Base.connection.execute sql
end

ejecuta_sql("
  DELETE FROM sivel2_gen_anexo_caso
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_etiqueta 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_contexto 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_categoria_presponsable 
    WHERE id_caso_presponsable IN ( SELECT id FROM 
      sivel2_gen_caso_presponsable WHERE id_caso IN (SELECT id FROM 
        sivel2_gen_caso WHERE id_caso<#{idini} or id_caso>#{idfin}));
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_respuestafor
    WHERE caso_id<#{idini} or caso_id>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_presponsable 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_usuario 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_acto 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_antecedente_victima WHERE 
    id_victima IN (SELECT id from sivel2_gen_victima 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_victima 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_actocolectivo 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  UPDATE sivel2_gen_caso SET ubicacion_id=NULL 
    WHERE id<#{idini} or id>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM msip_ubicacion 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_antecedente_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_filiacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_organizacion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_profesion_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_rangoedad_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_sectorsocial_victimacolectiva WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_victimacolectiva_vinculoestado WHERE 
    victimacolectiva_id IN (SELECT id FROM sivel2_gen_victimacolectiva 
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_victimacolectiva 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_antecedente_caso 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_region 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM sivel2_gen_caso_frontera 
    WHERE id_caso<#{idini} or id_caso>#{idfin};
    ")
ejecuta_sql("
  DELETE FROM msip_grupoper
    WHERE id IN (select id_grupoper FROM sivel2_gen_victimacolectiva
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM msip_persona_trelacion
    WHERE persona1 IN (SELECT id_persona FROM sivel2_gen_victima
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")
ejecuta_sql("
  DELETE FROM msip_persona_trelacion
    WHERE persona2 IN (SELECT id_persona FROM sivel2_gen_victima
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")

ejecuta_sql("
  DELETE FROM msip_persona
    WHERE id IN (select id_persona FROM sivel2_gen_victima
      WHERE id_caso<#{idini} or id_caso>#{idfin});
    ")

ejecuta_sql("
  DELETE FROM sivel2_gen_caso 
    WHERE id<#{idini} or id>#{idfin};
    ")
