require 'rails_helper'

RSpec.describe "Tenants", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/tenants/index"
      expect(response).to have_http_status(:success)
    end
  end

end
