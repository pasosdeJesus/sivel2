class MapatiempoController < ApplicationController

  
  # No se autoriza con una clase porque no la hay, debe ser función a función
  
  def mapatiempo
    authorize! :read, Sivel2Gen::contar
    render :mapatiempo, layout: 'application'
    return
  end

  def datoscovid
    render :file => '/public/data/all.json', 
      :content_type => 'application/json',
      :layout => false
  end

  def worldjson
    render :file => '/public/maps/WORLD.json', 
      :content_type => 'application/json',
      :layout => false
  end

  def colombia
    render :file => '/public/maps/gadm36_COL_1.json', 
      :content_type => 'application/json',
      :layout => false
  end
end
