# Agrega etiquetas a los casos de un perido y las actualizaciones
#
# Ejecutar con:
# bin/rails runner -e production scripts/agrega_etiqueta_periodo.rb 2022-01-01 2022-06-30 NYN65 AC-65 AI-65 juanperez


fini = ARGV[0]
if fini.nil? 
  puts "Primer parametro debe ser fecha inicial"
  exit 1
end
fini = Date.strptime(fini)
puts "Fecha inicial del periodo: #{fini}"

ffin = ARGV[1] 
if ffin.nil?
  puts "Segundo parametro debe ser fecha final"
  exit 1
end
ffin = Date.strptime(ffin)
puts "Fecha final del periodo: #{ffin}"

etinyn = ARGV[2] 
if etinyn.nil? || Sip::Etiqueta.where(nombre: etinyn).count != 1
  puts "Tercer parametro debe ser nombre de etiqueta existente (e.g NYN65 pero no '#{etinyn.to_s}')."
  exit 1
end
etinyn = Sip::Etiqueta.where(nombre: etinyn).take
puts "Etiqueta de la revista: #{etinyn.id}"

etic = ARGV[3] 
if etic.nil? || Sip::Etiqueta.where(nombre: etic).count != 1
  puts "Cuarto parametro debe ser nombre de etiqueta de actualizaciones completas de la revista #{etinyn.nombre} (e.g AC-65 pero no '#{etic.to_s}')."
  exit 1
end
etic = Sip::Etiqueta.where(nombre: etic).take
puts "Etiqueta de actualizaciones completas: #{etic.id}"

etii = ARGV[4] 
if etii.nil? || Sip::Etiqueta.where(nombre: etii).count != 1
  puts "Cuarto parametro debe ser nombre de etiqueta de actualizaciones incompletos de la revista #{etinyn.nombre} (e.g AI-65 pero no '#{etii.to_s}')."
  exit 1
end
etii = Sip::Etiqueta.where(nombre: etii).take
puts "Etiqueta de actualizaciones incompletas: #{etii.id}"

usuario = ARGV[5] 
if usuario.nil? || ::Usuario.where(nusuario: usuario).count != 1
  puts "Quinto parametro debe ser usuario que hará cambios en etiquetas para la revista #{etinyn.nombre} (e.g juanperez pero no '#{usuario.to_s}')."
  exit 1
end
usuario = Usuario.where(nusuario: usuario).take
puts "Usuario que hará cambios: #{usuario.id}"

if fini > ffin
  puts "Fecha de finalización del periodo debería ser mayor o igual a la de inicio"
  exit 1;
end

if etic == etii || etinyn == etic || etinyn == etii
  puts "Etiquetas deben ser diferentes"
  exit 1;
end

def ejecuta_sql(sql)
  puts "+ #{sql}"
  ActiveRecord::Base.connection.execute sql
end

cp = Sivel2Gen::Caso.where(
  "(fecha>=? AND fecha<=?)", fini, ffin ).count
puts "Casos del periodo: #{cp}"
ac = Sivel2Gen::Caso.where(
  "id IN (SELECT id_caso FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)",
  etic).count
puts "Actualizaciones completas: #{ac}"
ai = Sivel2Gen::Caso.where(
  "id IN (SELECT id_caso FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)",
  etii).count
puts "Actualizaciones incompletas: #{ai}"

tote = cp+ac+ai
puts "Total esperado de casos: #{tote}"

cn = Sivel2Gen::Caso.where(
  "(fecha>=? AND fecha<=?) 
     OR id IN (SELECT id_caso 
       FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)
     OR id IN (SELECT id_caso 
       FROM sivel2_gen_caso_etiqueta WHERE id_etiqueta=?)", 
       fini, ffin, etic.id, etii.id
).all
puts "Total de casos presentes en base para la revista: #{cn.count}"
if tote != cn.count
  puts "Deberían coincidir el total esperado y el que hay en base. Puede que haya actualizaciones con fecha del periodo, corregir"
  exit 1;
end
puts "Agregando etiqueta #{etinyn.nombre} a casos del periodo (pero no a actualizaciones para facilitar reproducir conteos de esta revista a futuro)."
le = []
Sivel2Gen::Caso.where("(fecha>=? AND fecha<=?)", fini, ffin ).all.each do |caso|
  if caso.etiqueta_ids.include?(etinyn.id) 
    puts "Caso #{caso.id} ya tiene etiqueta #{etinyn.nombre}"
  else
    e = Sivel2Gen::CasoEtiqueta.create!(
      id_caso: caso.id,
      id_etiqueta: etinyn.id,
      id_usuario: usuario.id,
      fecha: Date.today
    )
    le << caso.id 
  end
end
puts "Etiqueta agregada a #{le.count} casos (#{le.join(',')})"

