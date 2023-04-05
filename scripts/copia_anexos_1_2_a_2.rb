# Convierte anexos de SIVeL 1.2 a 2
#
# Ejecutar con:
# bin/rails runner -e production scripts/copia_anexos_1_2_a_2.rb  /ruta/a/anexos/sivel1.2/

#require 'byebug'

ranexos = '/var/www/resbase/anexos'
if ARGV[1] 
  ranexos = ARGV[1]
end

num = 0
numsin = 0
numvarios = 0
numrecodnom = 0
numrecodnom2 = 0

tot = Sivel2Gen::AnexoCaso.all.count
ultpor = -1
Sivel2Gen::AnexoCaso.all.each do |r|
  num += 1
  por = num*100/tot
  if por.to_i > ultpor
    ultpor = por.to_i
    puts "Porcentaje procesado: #{por}%"
  end
  #puts "#{r.caso_id}_#{r.id}"
  f = Dir["#{ranexos}/#{r.caso_id}_#{r.id}_*"]
  if f.count == 0 
    puts "No existe archivo para #{r.caso_id}_#{r.id}"
    numsin += 1
  elsif f.count > 1
    puts "Más de un archivo asociado a #{r.caso_id}_#{r.id}"
    numvarios += 1
  else
    # Si el nombre del archivo está codificado en LATIN1 copiarlo en otro 
    # con codificación UTF-8 y subir el otro
    if f[0].force_encoding('iso-8859-1').encode('utf-8') != f[0]
      numrecodnom += 1
      #byebug
      puts "Se necesita recodificar antes de abrir '#{f[0]}'"
      fl = f[0].force_encoding('iso-8859-1')
      sinesp = File.basename(fl).gsub(/[^-._0-9a-zA-Z]/,'_')
      narc = "/tmp/#{sinesp.encode('utf-8')}"
      #puts "Por ejecutar: "
      ord ="cp \"#{fl}\" \"#{narc}\" 2>&1 >> /tmp/errconv.err"
      # orde es latin1, pero el siguiente puts lo muestra sin
      # caracteres especiales porque seguramente la terminal
      # es abierta por ruby en modo utf-8 (?) 
      #puts "#{ord}"
      #puts "Ejecutando"
      # Sin embargo para que el siguiente lo hace bien
      res=`#{ord}`
      puts res
      if (!File.exist?(narc)) 
        numrecodnom2 += 1
        # Otro método
        puts "Creando archivo /tmp/orden-rb.sh"
        f = File.open("/tmp/orden-rb.sh", "w:iso-8859-1")
        f.write "#{ord}"
        f.close
        puts "Creado"
        res = `sh /tmp/orden-rb.sh`
        puts res
      end
    else
      narc = f[0]
    end
    g = File.new(narc)
    r.msip_anexo.adjunto=g
    r.save!
    #byebug
    g.close
  end
end
puts "Fin de procesamiento"
puts "Total de anexos procesados: #{num}"
puts "Total de anexos que hacen faltan: #{numsin}"
puts "Total de anexos con identificacion duplicada: #{numvarios}"
puts "Total de anexos que requirieron recodificacion del nombre: #{numrecodnom}"
puts "Total de anexos que para la recodificación requirieron segundo método: #{numrecodnom2}"

