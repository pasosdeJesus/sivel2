# encoding: UTF-8

require 'spec_helper'

describe "Llenar caso con javascript", :js => true do

  before { 
    usuario = Usuario.find_by(nusuario: 'sivel2')
    usuario.password = 'sivel2'
    visit '/usuarios/sign_in'
    fill_in "Usuario", with: usuario.nusuario
    fill_in "Clave", with: usuario.password
    click_button "Iniciar Sesión"
    #print page.html
    #page.save_screenshot('s.png')
    #save_and_open_page
    expect(page).to have_content("Administrar")
  }

  describe "administrador llena" do
    it "puede crear caso" do
      visit "/casos/nuevo"
      @numcaso=find_field('Código').value

      # Datos básicos
      fill_in "Fecha del Hecho", with: '2014-08-03'
      fill_in "Titulo", with: 'descripcion con javascript'

#      click_button "Guardar"
#      expect(page).to have_content("2014-08-03")
        # Núcleo familiar
        #page.save_screenshot('vic-1.png')
        #page.find(:xpath, "a[href='#victima']").click
        click_on "Víctimas"
        #page.save_screenshot('vic0.png')
        if (!find_link('Añadir Víctima').visible?)
          click_on "Víctimas"
        end
        #page.save_screenshot('/tmp/vic.png')
        click_on "Añadir Víctima"
        #page.save_screenshot('/tmp/vic2.png')
        #puts page.html
        if (!find_field('Año de nacimiento').visible?)
          click_on "Añadir Víctima"
          #page.save_screenshot('/tmp/vic3.png')
        end
        within ("div#victima") do 
          fill_in "Nombres", with: 'Nombres V'
          fill_in "Apellidos", with: 'Apellidos V'
          page.save_screenshot('/tmp/vic2-5.png')
          select("1999", from: "Año de nacimiento")
          select("ENERO", from: "Mes de nacimiento")
          select("1", from: "Día de nacimiento")
          select("MASCULINO", from: 'Sexo')
          select("CÉDULA DE CIUDADANÍA", from: 'Tipo de Documento')
          fill_in "Número Documento", with: '19222'
          select('ALBANIA', from: 'País de Nacionalidad')
          select('RUSIA', from: 'País de Nacimiento')
          select('OTRO', from: 'Profesión')
          #select('De 0 a 15 Años', from: 'Rango de Edad')
          select('ROM', from: 'Etnia') 
          select('IGLESIA DE DIOS', from: 'Religión/Iglesia') 
          select('HETEROSEXUAL', from: 'Orientación Sexual') 
        end
        #click_button "Guardar"
        #expect(page).to have_content("2014-08-03")

        # Sitios Geográficos
        #click_on "Editar"
        #page.save_screenshot('tmp/antes-ubi.png')
        click_link "Ubicación"
        if (!find_link('Añadir Ubicación').visible?)
          click_link "Ubicación"
        end
        expect(page).to have_content "Añadir Ubicación"
        click_on "Añadir Ubicación"
        page.save_screenshot('au-pais.png')
        if (!page.has_content?('Latitud'))
          click_on "Añadir Ubicación"
        end
        within ("div#ubicacion") do 
          select('VENEZUELA', from: 'País') 
          select('ARAGUA', from: 'Estado/Departamento') 
          select('CAMATAGUA', from: 'Municipio') 
          select('CARMEN DE CURA', from: 'Centro Poblado') 
          fill_in "Lugar", with: 'Lugar'
          fill_in "Sitio", with: 'Sitio'
          fill_in "Latitud", with: '4.1'
          fill_in "Longitud", with: '-74.3'
          select('URBANO', from: 'Tipo de Sitio') 
        end
        click_on "Añadir Ubicación"
        su = "//div[@id='ubicacion']/div[2]"
        within(:xpath, su) do 
          select('COLOMBIA', from: 'País') 
          select('BOYACÁ', from: 'Estado/Departamento') 
          select('CHISCAS', from: 'Municipio') 
          select('CHISCAS', from: 'Centro Poblado') 
          fill_in "Lugar", with: 'Lugar2'
          fill_in "Sitio", with: 'Sitio2'
          fill_in "Latitud", with: '4.2'
          fill_in "Longitud", with: '-74.32'
          select('RURAL', from: 'Tipo de Sitio') 
        end
        click_button "Guardar"
        expect(page).to have_content("2014-08-03")
    end
  end

end
