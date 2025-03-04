# frozen_string_literal: true

Rails.application.routes.draw do
  devise_scope :usuario do
    get "sign_out" => "devise/sessions#destroy"
    get "salir" => "devise/sessions#destroy",
      as: :terminar_sesion

    post "usuarios/iniciar_sesion", to: "devise/sessions#create"
    get "usuarios/iniciar_sesion",
      to: "devise/sessions#new",
      as: :iniciar_sesion

    # El siguiente para superar mala generación del action en el formulario
    # cuando se monta en sitio diferente a / y se autentica mal (genera
    # /puntomontaje/puntomontaje/usuarios/sign_in )
    if Rails.configuration.relative_url_root != "/"
      ruta = File.join(
        Rails.configuration.relative_url_root,
        "usuarios/sign_in",
      )
      post ruta, to: "devise/sessions#create"
      get  ruta, to: "devise/sessions#new"
    end
  end

  devise_for :usuarios, skip: [:registrations], module: :devise
  as :usuario do
    get "usuarios/edit" => "devise/registrations#edit",
      :as => "editar_registro_usuario"
    put "usuarios/:id" => "devise/registrations#update",
      :as => "registro_usuario"
  end
  resources :usuarios, path_names: { new: "nuevo", edit: "edita" }

  get "/casos/mapaosm" => "sivel2_gen/casos#mapaosm"

  root "sivel2_gen/hogar#index"
  # scope

  mount Msip::Engine, at: "/", as: "msip"
  mount Mr519Gen::Engine, at: "/", as: "mr519_gen"
  mount Heb412Gen::Engine, at: "/", as: "heb412_gen"
  mount Sivel2Gen::Engine, at: "/", as: "sivel2_gen"
end
