require 'rails_helper'

RSpec.describe "Inquiries", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/inquiries/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/inquiries/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/inquiries/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/inquiries/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
