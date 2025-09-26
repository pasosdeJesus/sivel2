# encoding: utf-8
# frozen_string_literal: true

require "sivel2_gen/concerns/controllers/conteos_controller"

module Sivel2Gen
  class ConteosController < ApplicationController
    include Sivel2Gen::Concerns::Controllers::ConteosController

    load_and_authorize_resource class: Sivel2Gen::Caso
  end
end
