# encoding: UTF-8
class ApplicationController < Sip::ApplicationController
  protect_from_forgery with: :exception
end

