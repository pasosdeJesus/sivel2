Rails.application.routes.draw do
  #devise_for :users, {
  #  class_name: 'Usuario',
  #  module: :devise
  #}

  devise_scope :usuario do
    get 'sign_out' => 'devise/sessions#destroy'
  end
  devise_for :usuarios, :skip => [:registrations], module: :devise
    as :usuario do
          get 'usuarios/edit' => 'devise/registrations#edit', 
            :as => 'editar_registro_usuario'    
          put 'usuarios/:id' => 'devise/registrations#update', 
            :as => 'registro_usuario'            
  end
  resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' } 

  root 'sivel2_gen/hogar#index'
  mount Sivel2Gen::Engine => "/", as: 'sivel2_gen'

end
