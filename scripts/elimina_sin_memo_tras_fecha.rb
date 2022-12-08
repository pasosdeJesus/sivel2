# Ejecutar con 
#bin/rails runner -e development scripts/elimina_sin_memo_tras_fecha.rb  2022-01-01

require_relative 'auxiliar_eliminar'

puts ARGV
fechaini = ARGV[0]
if fechaini.nil? 
  puts "Primer parametro debe ser fecha desde la cual eliminar sin memo y no '#{fechaini}'"
  exit 1
end
fechaini = Msip::FormatoFechaHelper.reconoce_adivinando_locale(fechaini)

eliminar_casos("SELECT id FROM sivel2_gen_caso WHERE fecha>='#{fechaini}' AND TRIM(memo)=''");

