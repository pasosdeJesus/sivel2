# encoding: UTF-8

require 'application_system_test_case'

class CasoconjsTest < ApplicationSystemTestCase

  test 'administrador crea' do
    # Reporta Error:
    # CasoconjsTest#test_administrador_crea:
    # CanCan::AccessDenied: No está autorizado para read sip/departamento/active record relation.
    @usuario = Usuario.find_by(nusuario: 'sivel2')
    @usuario.password = 'sivel2'
    visit File.join(Rails.configuration.relative_url_root, '/usuarios/sign_in')
    fill_in "Usuario", with: @usuario.nusuario
    fill_in "Clave", with: @usuario.password
    click_button "Iniciar Sesión"
    assert page.has_content?("Administrar")

    visit File.join(Rails.configuration.relative_url_root, '/casos/nuevo')
    take_screenshot
    @numcaso=find_field('Caso No.').value

    # Datos básicos
    fill_in "Fecha del hecho", with: '2014-08-05'
    fill_in "Título", with: 'titulo'

    take_screenshot
    click_on "Víctimas"
    lav=find_link('Añadir Víctima')
    if (!lav.visible?)
      click_on "Víctimas"
    end
    click_on 'Añadir Víctima'
    take_screenshot
    within ("div#victima") do 
      fill_in "Nombres", with: 'Nombres V'
      fill_in "Apellidos", with: 'Apellidos V'
      select("1999", from: 'Año de nacimiento')
      select("ENERO", from: 'Mes de nacimiento')
      select("1", from: 'Día de nacimiento')
      select("MASCULINO", from: 'Sexo')
      select("CÉDULA DE CIUDADANÍA", from: 'Tipo de documento')
      fill_in "Número de documento", with: '19222'
      #select('ALBANIA', from: 'País de Nacionalidad')
      select('RUSIA', from: 'País de nacimiento')
      select('OTRO', from: 'Profesión')
      select('ROM', from: 'Etnia') 
      select('IGLESIA DE DIOS', from: 'Religión/Iglesia') 
      select('HETEROSEXUAL', from: 'Orientación sexual') 
    end
    page.save_screenshot('/tmp/s2-ccj-trasvictima')

    click_link "Ubicación"
    if (!find_link('Añadir Ubicación').visible?)
      click_link "Ubicación"
    end
    assert page.has_content?("Añadir Ubicación")
    click_on "Añadir Ubicación"
    if (!page.has_content?('Latitud'))
      click_on "Añadir Ubicación"
    end
    within ("div#ubicacion") do 
      assert page.has_select?('País')
      select('VENEZUELA', from: 'País') 
      assert page.has_select?('País', selected: 'VENEZUELA')
      puts "Eligió país"
      assert page.has_select?('Departamento/Estado/Cantón', with_options: ['ARAGUA'])
      puts "Lleno con AJAX departamento"
      # Capybara+poltergeist+phantomjs 1.9.8 no permiten lo siguiente
      if false
        # La siguiente impide Guardar con error Internal Server Error
        select('ARAGUA', from: 'Departamento/Estado/Cantón') 
        puts "Eligió departamento"
        page.save_screenshot('/tmp/s2-traselegirdepto')
        puts "Esperando Municipio con AJAX"
        # Los siguientes bloquean o presentan error 
        rc = page.evaluate_script("$.active").to_i
        puts "rc=#{rc}"
        while  rc>0
          rc = page.evaluate_script("$.active").to_i
          puts "rc=#{rc}"
        end
        puts "Esperando Municipio con AJAX 2"
        assert page.has_select?('Municipio', with_options: ['CAMATAGUA'])
        puts "Lleno con AJAX municipio"
        select('CAMATAGUA', from: 'Municipio') 
        puts "Eligió municipio"
        assert page.has_select?('Centro Poblado', with_options: ['CARMEN DE CURA'])
        puts "Lleno con AJAX Centro Poblado"
        select('CARMEN DE CURA', from: 'Centro Poblado') 
        puts "Eligió Centro Poblado"
      end
      fill_in "Lugar", with: 'Lugar'
      fill_in "Sitio", with: 'Sitio'
      fill_in "Latitud", with: '4.1'
      fill_in "Longitud", with: '-74.3'
      select('URBANO', from: 'Tipo de sitio') 
    end
    page.save_screenshot('/tmp/s2-ccj-trasubicacion')
    click_on "Añadir Ubicación"
    su = "//div[@id='ubicacion']/div[2]"
    within(:xpath, su) do 
      select('COLOMBIA', from: 'País') 
      assert page.has_select?('Departamento/Estado/Cantón', with_options: ['BOYACÁ'])
      rc = page.evaluate_script("$.active").to_i
      puts "hay depto rc=#{rc}"
      if false
        select('BOYACÁ', from: 'Departamento/Estado/Cantón') 
        select('CHISCAS', from: 'Municipio') 
        select('CHISCAS', from: 'Centro Poblado') 
      end
      fill_in "Lugar", with: 'Lugar2'
      fill_in "Sitio", with: 'Sitio2'
      fill_in "Latitud", with: '4.2'
      fill_in "Longitud", with: '-74.32'
      select('RURAL', from: 'Tipo de sitio') 
    end

    puts "Guardando"
    click_button "Guardar"
    puts page.html
    assert page.has_content?("2014-08-05")
  end

end
