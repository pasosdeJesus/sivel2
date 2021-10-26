class MapatiempoController < ApplicationController

  
  load_and_authorize_resource class: ::Mapatiempo

  def mapatiempo
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
