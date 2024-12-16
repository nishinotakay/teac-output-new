# frozen_string_literal: true

module Admins
  class ConfirmationsController < Devise::ConfirmationsController
    layout 'admins'
    # GET /resource/confirmation/new
    # def new
    #   super
    # end

    # POST /resource/confirmation
    # def create
    #   super
    # endåç

    # GET /resource/confirmation?confirmation_token=abcdef
    # def create

    #protected

    # The path used after resending confirmation instructions.
    # def after_resending_confirmation_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    #The path used after confirmation.
    #def after_confirmation_path_for(resource_name, resource)
      #new_tenant_admin_admin_session_path(tenant_id: resource.tenant_id)#   super(resource_name, resource)
    #end
  end
end
