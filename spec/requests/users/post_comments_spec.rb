require 'rails_helper'

RSpec.describe "Users::PostComments", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/users/post_comments/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/users/post_comments/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/users/post_comments/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
