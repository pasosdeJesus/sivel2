# Agrega etiqueta NyN con número de revista a los casos de un perido y las actualizaciones
#
# Ejecutar con:
# bin/rails runner -e production scripts/quita_etiquetas_revista_redundantes.rb NYN65 AC-65 AI-65 

#require 'byebug'

etinyn = ARGV[0] 
if etinyn.nil? || Sip::Etiqueta.where(nombre: etinyn).count != 1
  puts "Primer parametro debe ser nombre de etiqueta para la revista (e.g NYN65 pero no '#{etinyn.to_s}')."
  exit 1
end
etinyn = Sip::Etiqueta.where(nombre: etinyn).take
puts "Etiqueta de la revista: #{etinyn.id}"

etic = ARGV[1] 
if etic.nil? || Sip::Etiqueta.where(nombre: etic).count != 1
  puts "Segundo parametro debe ser nombre de etiqueta de actualizaciones completas de la revista #{etinyn.nombre} (e.g AC-65 pero no '#{etic.to_s}')."
  exit 1
end
etic = Sip::Etiqueta.where(nombre: etic).take
puts "Etiqueta de actualizaciones completas: #{etic.id}"

etii = ARGV[2] 
if etii.nil? || Sip::Etiqueta.where(nombre: etii).count != 1
  puts "Tercer parametro debe ser nombre de etiqueta de actualizaciones incompletos de la revista #{etinyn.nombre} (e.g AI-65 pero no '#{etii.to_s}')."
  exit 1
end
etii = Sip::Etiqueta.where(nombre: etii).take
puts "Etiqueta de actualizaciones incompletas: #{etii.id}"

if etic == etii || etinyn == etic || etinyn == etii
  puts "Etiquetas deben ser diferentes"
  exit 1;
end

def ejecuta_sql(sql)
  puts "+ #{sql}"
  ActiveRecord::Base.connection.execute sql
end

ac = Sivel2Gen::Caso.where(
  "id IN (SELECT id_caso FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)",
  etic).count
puts "Actualizaciones completas: #{ac}"
ai = Sivel2Gen::Caso.where(
  "id IN (SELECT id_caso FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)",
  etii).count
puts "Actualizaciones incompletas: #{ai}"

cn = Sivel2Gen::Caso.where(
   "id IN (SELECT id_caso 
       FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)
     OR id IN (SELECT id_caso 
       FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)", 
       etic.id, etii.id
).all
puts "Total de casos con actualizaciones: #{cn.count}"
puts "Quitando etiqueta #{etinyn.nombre} a casos con actualizaciones."
lq = []
cn.all.each do |caso|
  if caso.etiqueta_ids.include?(etinyn.id) 
    puts "Caso #{caso.id} tiene etiquetas #{etinyn.nombre} (#{caso.etiqueta_ids}). Eliminandola"
    Sivel2Gen::CasoEtiqueta.where(id_etiqueta: etinyn.id,
                                  id_caso: caso.id).destroy_all
    lq << caso.id 
  end
end
puts "Etiqueta #{etinyn.nombre} eliminada de #{lq.count} casos (#{lq.join(',')})"

