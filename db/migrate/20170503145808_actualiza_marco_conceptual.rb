class ActualizaMarcoConceptual < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
    -- A y B 
    UPDATE sivel2_gen_categoria SET nombre='LESIÓN FÍSICA' WHERE id in ('13', '23', '33', '43', '53'); -- HERIDO->LESIÓN FÍSICA
   
    -- A 
    UPDATE sivel2_gen_categoria SET nombre='DESAPARICIÓN FORZADA' WHERE id in ('11', '21', '302'); -- Añadida FORZADA

    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('17', 'COLECTIVO LESIONADO', '1', 'C');
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('231', 'COLECTIVO LESIONADO', '5', 'C');
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('331', 'COLECTIVO LESIONADO', '8', 'C');

    UPDATE sivel2_gen_categoria SET nombre='DESPLAZAMIENTO FORZADO' WHERE id in ('102'); -- COLECTIVO -> FORZADO
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('27', 'DESPLAZAMIENTO FORZADO', '5', 'C');
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('34', 'DESPLAZAMIENTO FORZADO', '8', 'C');

    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('141', 'JUDICIALIZACIÓN ARBITRARIA', '1', 'I');
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('241', 'JUDICIALIZACIÓN ARBITRARIA', '5', 'I');
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('341', 'JUDICIALIZACIÓN ARBITRARIA', '8', 'I');

    UPDATE sivel2_gen_categoria SET nombre='VIOLACION' WHERE id IN  ('191', '291', '391'); -- Se quita V.S. -
    UPDATE sivel2_gen_categoria SET nombre='EMBARAZO FORZADO' WHERE id IN ('192', '292', '392'); -- Se quita V.S. -
    UPDATE sivel2_gen_categoria SET nombre='PROSTITUCIÓN FORZADA' WHERE id IN ('193', '293', '393'); -- Se quita V.S. -
    UPDATE sivel2_gen_categoria SET nombre='ESTERILIZACIÓN FORZADA' WHERE id IN ('194', '294', '394'); -- Se quita V.S. -
    UPDATE sivel2_gen_categoria SET nombre='ESCLAVITUD SEXUAL' WHERE id IN ('195', '295', '395'); -- Se quita V.S. -
    UPDATE sivel2_gen_categoria SET nombre='ABUSO SEXUAL' WHERE id IN ('196', '296', '396'); -- Se quita V.S. -
    UPDATE sivel2_gen_categoria SET nombre='ABORTO FORZADO' WHERE id IN ('197', '297', '397'); -- Se quita V.S. -
    
    UPDATE sivel2_gen_categoria SET nombre='CONFINAMIENTO COLECTIVO' WHERE id in ('104'); -- Se quita COMO REPRESALIA O CASTIGO
 
    -- B 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('402', 'COLECTIVO LESIONADO', '2', 'C');
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('502', 'COLECTIVO LESIONADO', '6', 'C');

    UPDATE sivel2_gen_categoria SET nombre='RAPTO' WHERE id='58'; --Era DESAPARICIÓN


    -- C
    UPDATE sivel2_gen_categoria SET nombre='AMETRALLAMIENTO Y/O BOMBARDEO' WHERE id in ('65');
    UPDATE sivel2_gen_categoria SET nombre='ATAQUE A OBJETIVO MILITAR' WHERE id in ('67');
    UPDATE sivel2_gen_categoria SET fechadeshabilitacion='2017-05-03' WHERE id in ('910'); -- ENFRENTAMIENTO INTERNO

    --D
    UPDATE sivel2_gen_categoria SET nombre='TOMA DE REHENES' WHERE id='74';

    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('76', 'DESAPARICIÓN FORZADA', '4', 'I');

    UPDATE sivel2_gen_categoria SET nombre='ESCUDO INDIVIDUAL' WHERE id in ('78');
    UPDATE sivel2_gen_categoria SET nombre='MUERTO POR ATAQUE A BIENES CIVILES' WHERE id in ('87'); -- EN->POR
    UPDATE sivel2_gen_categoria SET nombre='LESIÓN POR ATAQUE A BIENES CIVILES' WHERE id in ('88'); -- EN->POR, HERIDO->LESIÓN
    UPDATE sivel2_gen_categoria SET nombre='MUERTO POR OBJETIVOS, MÉTODOS Y MEDIOS ILÍCITOS' WHERE id in ('97'); -- Añadido OBJETIVOS
    UPDATE sivel2_gen_categoria SET nombre='LESIÓN POR OBJETIVOS, MÉTODOS Y MEDIOS ILÍCITOS' WHERE id in ('98'); -- Añadido OBJETIVOS, HERIDO -> LESIÓN
    UPDATE sivel2_gen_categoria SET nombre='LESIÓN A PERSONA PROTEGIDA' WHERE id in ('702'); -- HERIDO INTENCIONAL -> LESIÓN A

    UPDATE sivel2_gen_categoria SET nombre='HOMICIDIO INTENCIONAL DE PERSONA PROTEGIDA ' WHERE id='701'; -- Se agregó DE
    UPDATE sivel2_gen_categoria SET nombre='CIVIL MUERTO EN ACCIÓN BÉLICA' WHERE id='703'; -- ACCIONES BÉLICAS -> ACCIÓN BÉLICA
    UPDATE sivel2_gen_categoria SET nombre='LESIÓN A CIVILES EN ACCIÓN BÉLICA' WHERE id in ('704'); -- CIVIL HERIDO -> LESIÓN A CIVILES

    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('705', 'COLECTIVO LESIONADO POR INFRACCIONES AL DIHC', '4', 'C'); 
   
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('714', 'ESCLAVITUD Y TRABAJOS FORZADOS', '4', 'I'); 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('715', 'JUDICIALIZACIÓN ARBITRARIA', '4', 'I'); 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('716', 'NEGACIÓN DE DERECHOS A PRISIONEROS DE GUERRA', '4', 'I'); 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('717', 'NEGACIÓN DE ATENCIÓN A PERSONAS VULNERABLES', '4', 'I'); 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('718', 'PROFANACIÓN Y OCULTAMIENTO DE CADÁVERES', '4', 'I'); 

    UPDATE sivel2_gen_categoria SET nombre='DESPLAZAMIENTO FORZADO' WHERE id ='903'; -- COLECTIVO DESPLAZADO -> DESPLAZAMIENTO FORZADO
    UPDATE sivel2_gen_categoria SET nombre='COLECTIVO ESCUDO' WHERE id ='904'; -- ESCUDO -> COLECTIVO ESCUDO
    UPDATE sivel2_gen_categoria SET nombre='CONFINAMIENTO COLECTIVO' WHERE id ='906'; -- COMO REPRESALIA O CASTIGO COLECTIVO -> COLECTIVO


    UPDATE sivel2_gen_supracategoria SET 
      nombre='OBJETIVOS, MÉTODOS Y MÉDIOS ILÍCITOS' WHERE id='7'; -- Era BIENES
    UPDATE sivel2_gen_supracategoria SET 
      fechadeshabilitacion='2017-05-03' WHERE id='9'; -- MÉTODOS
    UPDATE sivel2_gen_categoria SET supracategoria_id='7' 
      WHERE supracategoria_id='9';

    UPDATE sivel2_gen_categoria SET nombre='MEDIO AMBIENTE' 
      WHERE id ='84'; -- Se quitó INFRACCIÓN CONTRA
    UPDATE sivel2_gen_categoria SET nombre='BIENES CULTURALES Y RELIGIOSOS' 
      WHERE id ='85'; -- Se quitó INFRACCIÓN CONTRA
    UPDATE sivel2_gen_categoria SET nombre='HAMBRE COMO MÉTODO DE GUERRA' 
      WHERE id ='86'; -- Era BIENES INDISPENSABLES PARA LA SUPERV. DE LA POB.
    UPDATE sivel2_gen_categoria SET nombre='ESTRUCTURA VIAL' 
      WHERE id ='89'; -- Se quitó INFRACCIÓN CONTRA LA
    UPDATE sivel2_gen_categoria SET nombre='ATAQUE A OBRAS E INST. QUE CONT. FUERZAS PELIGR.' 
      WHERE id ='801'; -- Era ATAQUE A OBRAS / INSTALACIONES QUE CONT. FUERZAS PELGIROSAS
    UPDATE sivel2_gen_categoria SET nombre='ATAQUE INDISCRIMINADO' WHERE id ='90'; -- Era AMETRALLAMIENTO Y/O BOMBARDEO INDISCRIMINADO
    UPDATE sivel2_gen_categoria SET nombre='ARMAS ABSOLUTAMENTE PROHIBIDAS' WHERE id ='92'; -- Era ARMA PROHIBIDA
    UPDATE sivel2_gen_categoria SET nombre='EMPLEO ILÍCITO DE ARMAS DE USO RESTRINGIDO' WHERE id ='93'; -- Era MINA ILÍCITA / ARMA TRAMPA
    UPDATE sivel2_gen_categoria SET nombre='MISIÓN MÉDICA O SANITARIA' WHERE id ='707'; -- Era INFRACCIÓN CONTRA MISIÓN MÉDICA
    UPDATE sivel2_gen_categoria SET nombre='MISIÓN RELIGIOSA' WHERE id ='708'; -- Se quitó INFRACCIÓN CONTRA
    UPDATE sivel2_gen_categoria SET nombre='MISIÓN HUMANITARIA' WHERE id ='709'; -- Se quitó INFRACCIÓN CONTRA

    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('710', 'MISIONES DE PAZ', '7', 'O'); 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('711', 'MISIÓN INFORMATIVA', '7', 'O'); 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('712', 'ZONAS HUMANITARIAS', '7', 'O'); 
    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('713', 'CONVERSACIONES DE PAZ', '7', 'O'); 

    UPDATE sivel2_gen_categoria SET nombre='DESPLAZAMIENTO FORZADO' WHERE id ='902'; -- Se quitó COLECTIVO

    INSERT INTO sivel2_gen_categoria (id, nombre, supracategoria_id, tipocat)
      VALUES ('905', 'GUERRA SIN CUARTEL', '7', 'O'); 

    -- Pregunta, desplazamiento forzado es colectivo, que tal desplazamiento forzado colectivo
    SQL
  end
  def down
    puts "OJO incompleta"
    execute <<-SQL
    -- A
    DELETE FROM sivel2_gen_categoria WHERE id IN (
      '17', '231', '331', '27', '34', 
      '141', '241', '341');

    -- B
    DELETE FROM sivel2_gen_categoria WHERE id IN ( 
      '402', '502');

    --D
    DELETE FROM sivel2_gen_categoria WHERE id IN ( 
      '76', '705', '714', '715', '716', '717',
      '718', '710', '711', '712','713', '905');
    SQL
  end
end
