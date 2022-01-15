require "application_system_test_case"

class IniciarSesionTest < ApplicationSystemTestCase

  test "iniciar sesión" do
    Sip::CapybaraHelper.iniciar_sesion(self, root_path, 'sip', 'sip')
  end

end
