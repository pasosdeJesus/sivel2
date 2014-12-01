# encoding: UTF-8
require 'spec_helper'

describe "Control de acceso " do
  before { 
    @usuario = FactoryGirl.create(:usuario, rol: Ability::ROLANALI)
                                  visit new_usuario_session_path 
                                  fill_in "Usuario", with: @usuario.nusuario
                                  fill_in "Clave", with: @usuario.password
                                  click_button "Iniciar Sesión"
                                  expect(page).to have_content("Administrar")
  }

  describe "analista" do
    it "puede crear caso" do
      visit "/casos/nuevo"
      @numcaso=find_field('Código').value

      # Datos básicos
      fill_in "Fecha del Hecho", with: '2014-08-05'
      fill_in "Titulo", with: 'titulo'
			click_button "Guardar"
		  expect(page).to have_content("2014-08-05")

      # Solicitante Principal
			click_on "Editar"
      fill_in "Hora", with: '3:00 PM'
      fill_in "Duracion", with: '2'
      select("ANTIOQUIA CHOCO SANT", from: 'Región')
      select("Ecuador", from: 'Frontera')
      click_button "Guardar"
		  expect(page).to have_content("2014-08-05") 
      #puts page.body
			# Driver no acepta: accept_confirm do click_on "Eliminar" end
		  #expect(page).to have_content("Casos")
    end

  end

end
