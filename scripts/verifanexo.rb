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
  if (!ac.sip_anexo)
    #byebug
    STDERR.puts "No se encontró sip_anexo en #{ac.id_caso}"
  elsif (!ac.sip_anexo.adjunto)
    #byebug
    STDERR.puts "No se encontró sip_anexo en #{ac.sip_anexo}"
  elsif (!ac.sip_anexo.adjunto.path)
    STDERR.puts "No hay path en #{ac.sip_anexo.descripcion}"
    u = Sivel2Gen::CasoUsuario.where(id_caso: ac.id_caso).order(:fechainicio)[0]
    puts "#{ac.id_caso}\t#{ac.id}\t#{ac.fecha}\t#{ac.sip_anexo.descripcion}\t\t#{u.usuario.nusuario}"
    numsinp += 1
  elsif (!File.exist?(ac.sip_anexo.adjunto.path)) 
    #byebug
    STDERR.puts "No se encontró #{ac.sip_anexo.adjunto.path}"
    u = Sivel2Gen::CasoUsuario.where(id_caso: ac.id_caso).order(:fechainicio)[0]
    puts "#{ac.id_caso}\t#{ac.id}\t#{ac.fecha}\t#{ac.sip_anexo.descripcion}\t#{ac.sip_anexo.adjunto.path}\t#{u.usuario.nusuario}"
    numsin += 1
  end
end

puts "Total: #{num}"
puts "Total de anexos sin path: #{numsinp}"
puts "Total de anexos con path pero no en sistema de archivos: #{numsin}"
