# Ejecutar con 
# bin/rails runner -e development scripts/elimina_datos_privados.rb 

ActiveRecord::Base.connection.execute <<-SQL
  DELETE FROM sivel2_gen_caso_etiqueta WHERE 
    etiqueta_id NOT IN (SELECT id FROM msip_etiqueta
    WHERE (nombre LIKE '%01%' or nombre like '%02%')
    AND NOT NOMBRE LIKE '%20%');

  DELETE FROM msip_etiqueta WHERE (nombre NOT IN ('AMARILLO',
    'AZUL', 'MES_INEXACTO', 'ROJO', 'VERDE')
    AND nombre NOT LIKE '%01%' AND nombre NOT like '%02%')
    OR NOMBRE LIKE '%20%';
  DELETE FROM sivel2_gen_caso_usuario ;
  DELETE FROM mr519_gen_encuestapersona;
  DELETE FROM mr519_gen_encuestausuario;
  DELETE FROM sivel2_gen_caso_fuenteprensa;
  DELETE FROM sivel2_gen_caso_fotra;
  DELETE FROM sivel2_gen_anexo_caso;
  DELETE FROM msip_anexo;
  DELETE FROM sivel2_gen_fotra;
  DELETE FROM msip_bitacora;
  DELETE FROM msip_grupo WHERE id NOT IN (20, 21, 25);
  UPDATE usuario SET nusuario='adminexp' WHERE id=1;
  INSERT INTO usuario (id, nusuario, fechacreacion)
    SELECT 1, 'adminexp', '2020-05-28'
      WHERE NOT EXISTS (SELECT 1 FROM usuario WHERE id=1);

  DELETE FROM msip_grupo_usuario WHERE usuario_id<>1;
  UPDATE sivel2_gen_caso_etiqueta SET usuario_id=1;
  DELETE FROM usuario WHERE id<>1;
  DELETE FROM msip_oficina ;
SQL
