# encoding: UTF-8

require 'spec_helper'

describe "Llenar caso con javascript", :js => true do

  before { 
    usuario = Usuario.find_by(nusuario: 'sivel2')
    usuario.password = 'sivel2'
    visit new_usuario_session_path 
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
      visit new_caso_path
      @numcaso=find_field('Código').value

      # Datos básicos
      fill_in "Fecha del Hecho", with: '2014-08-03'
      fill_in "Titulo", with: 'descripcion con javascript'

      # Núcleo familiar
      click_on "Víctimas"
      click_on "Añadir Víctima"
      within ("div#victima") do 
        fill_in "Nombres", with: 'Nombres V'
        fill_in "Apellidos", with: 'Apellidos V'
        fill_in "Año Nacimiento", with: '1999'
        fill_in "Mes Nacimiento", with: '1'
        fill_in "Día Nacimiento", with: '1'
        select("MASCULINO", from: 'Sexo')
        select("CÉDULA DE CIUDADANÍA", from: 'Tipo de Documento')
        fill_in "Número Documento", with: '19222'
        select('ALBANIA', from: 'País de Nacionalidad')
        select('RUSIA', from: 'País de Nacimiento')
        select('OTRO', from: 'Profesión')
        select('De 0 a 15 Años', from: 'Rango de Edad')
        select('ROM', from: 'Etnia') 
        select('IGLESIA DE DIOS', from: 'Religión/Iglesia') 
        select('HETEROSEXUAL', from: 'Orientación Sexual') 
      end
      click_button "Guardar"
      expect(page).to have_content("2014-08-03")

      # Sitios Geográficos
      click_on "Editar"
      click_link "Ubicación"
      if (!find_link('Añadir Ubicación').visible?)
        click_link "Ubicación"
      end
      expect(page).to have_content "Añadir Ubicación"
      click_on "Añadir Ubicación"
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
      su = "//div[@id='ubicacion']/div/div[2]"
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
