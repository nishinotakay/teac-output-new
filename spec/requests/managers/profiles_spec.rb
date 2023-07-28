require 'rails_helper'

RSpec.describe "Managers::Profiles", type: :request do
  describe "GET /managers_show" do
    it "returns http success" do
      get "/managers/profiles/managers_show"
      expect(response).to have_http_status(:success)
    end
  end

end
