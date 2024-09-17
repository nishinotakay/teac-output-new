# frozen_string_literal: true

module Admins
  class Base < ApplicationController
    before_action :authenticate_admin!
    layout 'admins'
  end
end
