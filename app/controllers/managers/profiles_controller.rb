module Managers  
  class ProfilesController < Managers::Base
    before_action :authenticate_manager!
    
    def managers_show
    end
  end
end