# Verifica que existan archivos referenciados en anexos, genera TSV de problemas en salida estándar
#
# Ejecutar con:
# bin/rails runner -e production scripts/verifanexo.rb

#require 'byebug'

num = 0
numsin = 0
numsinp = 0
tot = Sivel2Gen::AnexoCaso.all.count
ultpor = -1
Sivel2Gen::AnexoCaso.all.each do |ac|
  num += 1
  por = num*100/tot
  if por.to_i > ultpor
    ultpor = por.to_i
    STDERR.puts "Porcentaje procesado: #{por}%"
  end
  if (!ac.msip_anexo)
    #byebug
    STDERR.puts "No se encontró msip_anexo en #{ac.id_caso}"
  elsif (!ac.msip_anexo.adjunto)
    #byebug
    STDERR.puts "No se encontró msip_anexo en #{ac.msip_anexo}"
  elsif (!ac.msip_anexo.adjunto.path)
    STDERR.puts "No hay path en #{ac.msip_anexo.descripcion}"
    u = Sivel2Gen::CasoUsuario.where(id_caso: ac.id_caso).order(:fechainicio)[0]
    puts "#{ac.id_caso}\t#{ac.id}\t#{ac.fecha}\t#{ac.msip_anexo.descripcion}\t\t#{u.usuario.nusuario}"
    numsinp += 1
  elsif (!File.exist?(ac.msip_anexo.adjunto.path)) 
    #byebug
    STDERR.puts "No se encontró #{ac.msip_anexo.adjunto.path}"
    u = Sivel2Gen::CasoUsuario.where(id_caso: ac.id_caso).order(:fechainicio)[0]
    puts "#{ac.id_caso}\t#{ac.id}\t#{ac.fecha}\t#{ac.msip_anexo.descripcion}\t#{ac.msip_anexo.adjunto.path}\t#{u.usuario.nusuario}"
    numsin += 1
  end
end

puts "Total: #{num}"
puts "Total de anexos sin path: #{numsinp}"
puts "Total de anexos con path pero no en sistema de archivos: #{numsin}"
