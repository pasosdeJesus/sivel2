# Ejecutar con 
# bin/rails runner -e development scripts/elimina_casos_antes_fecha_que_no_son_actualizacion.rb 2001-01-01

require_relative 'auxiliar_eliminar'

puts ARGV
fechaini = ARGV[0]
if fechaini.nil? 
  puts "Primer parametro debe ser fecha hasta la cual eliminar y no '#{fechaini}'"
  exit 1
end
fechaini = Msip::FormatoFechaHelper.reconoce_adivinando_locale(fechaini)

ids_por_eliminar = "SELECT id FROM sivel2_gen_caso WHERE fecha<='#{fechaini}'
    AND id NOT IN (SELECT DISTINCT id_caso FROM sivel2_gen_caso_etiqueta 
      WHERE id_etiqueta IN (SELECT id FROM msip_etiqueta 
        WHERE (nombre LIKE '%01%' or nombre like '%02%') 
        AND NOT NOMBRE LIKE '%20%'
      )
    )"

eliminar_casos(ids_por_eliminar)

