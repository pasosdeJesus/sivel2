
# encoding: UTF-8

require 'application_system_test_case'

class UsuarioTest < ApplicationSystemTestCase

  test "no autentica" do
    skip
    usuario = Usuario.find_by(nusuario: 'sivel2') 
    visit File.join(Rails.configuration.relative_url_root, '/usuarios/sign_in') 
    fill_in "Usuario", with: usuario.nusuario
    fill_in "Clave", with: 'ERRADA' 
    click_button "Iniciar Sesión"
    assert_not page.has_content?("Administrar")
  end

  test "autentica con usuario existente en base inicial" do
    skip
    usuario = Usuario.find_by(nusuario: 'sivel2')
    visit File.join(Rails.configuration.relative_url_root, '/usuarios/sign_in')
    usuario.password = 'sivel2'
    fill_in "Usuario", with: usuario.nusuario
    fill_in "Clave", with: usuario.password
    click_button "Iniciar Sesión"
    assert page.has_content?("Administrar")
  end

end
