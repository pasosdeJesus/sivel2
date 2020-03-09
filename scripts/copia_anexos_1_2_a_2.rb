# Ejecutar con 
# bin/rails runner -e production scripts/elimina_datos_privados.rb  /ruta/a/anexos/sivel1.2/

ranexos = '/var/www/resbase/anexos'
if ARGV[1] 
  ranexos = ARGV[1]
end

Sivel2Gen::AnexoCaso.all.each do |r|
  f = Dir["#{ranexos}/#{r.id_caso}_#{r.id}_*"]
  if f.count == 0 
    puts "No existe archivo para #{r.id_caso}_#{r.id}"
  elsif f.count > 1
    puts "Más de un archivo asociacio a #{r.id_caso}_#{r.id}"
  else
    g = File.new(f[0])
    r.sip_anexo.adjunto=g
    r.save!
    g.close
  end
end
puts "Fin de procesamiento"

