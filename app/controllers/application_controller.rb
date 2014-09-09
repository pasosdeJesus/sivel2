# encoding: UTF-8
require 'sivel2_gen/application_controller'
class ApplicationController < Sivel2Gen::ApplicationController
  protect_from_forgery with: :exception
end

