# frozen_string_literal: true

module Managers
  class Base < ApplicationController
    before_action :authenticate_manager!
    layout 'managers'
  end
end
