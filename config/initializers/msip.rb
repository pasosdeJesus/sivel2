require 'sivel2_gen/version'

Msip.setup do |config|
  config.ruta_anexos = ENV.fetch('MSIP_RUTA_ANEXOS', 
                                 "#{Rails.root}/archivos/anexos/")
  config.ruta_volcados = ENV.fetch('MSIP_RUTA_VOLCADOS',
                                   "#{Rails.root}/archivos/bd/")
  # En heroku los anexos son super-temporales
  if ENV["HEROKU_POSTGRESQL_MAUVE_URL"]
    config.ruta_anexos = "#{Rails.root}/tmp/"
  end
  config.titulo = ENV.fetch('MSIP_TITULO', "SIVeL").dup.force_encoding('UTF-8') + " #{Sivel2Gen::VERSION}"

  config.descripcion = "Sistema de Información de Violencia Política en Línea"
  config.codigofuente = "https://github.com/pasosdeJesus/sivel2"
  config.urlcontribuyentes = "https://github.com/pasosdeJesus/sivel2/graphs/contributors"
  config.urlcreditos = "https://github.com/pasosdeJesus/sivel2/blob/main/CREDITOS.md"
  config.agradecimientoDios = "<p>
El mayor agradecimiento al Dios trino, el de la Biblia, a quien dedicamos 
este trabajo y a quien oramos para que no sea usado por estructuras armadas
sino para oponernos a la violencia y a la corrupción y para darle honra a Él.
</p>
<blockquote>
SEÑOR, tú escucharás las oraciones de la gente humilde
y le darás ánimo a su corazón; préstales atención.
Protege a los indefensos, haz justicia a los pobres y oprimidos,
y que el ser humano no cause más violencia sobre la tierra.
Cantaré a Jehová, <br>
Porque me ha hecho bien.
<br>
Salmo 13:6
</blockquote>
".html_safe

end
