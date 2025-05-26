# frozen_string_literal: true

Sivel2::Application.config.relative_url_root = ENV.fetch(
  "RUTA_RELATIVA", "/sivel2"
)
Sivel2::Application.config.assets.prefix = if ENV.fetch(
  "RUTA_RELATIVA", "/sivel2"
) == "/"
  "/assets"
else
  (ENV.fetch("RUTA_RELATIVA", "/sivel2_2") + "/assets")
end
