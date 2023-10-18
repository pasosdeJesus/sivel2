class ApplicationController < Sivel2Gen::ApplicationController
  protect_from_forgery with: :exception

  # No requiere autorización
end

