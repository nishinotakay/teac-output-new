# frozen_string_literal: true

module Users
  class DashBoardsController < Users::Base
    def index
      @articles = current_user.articles.all.order(updated_at: "DESC")
      # @articles = current_user.articles.all
      # params[:sort] ||= "DESC"
      # params[:order] ||= "updated_at"
      # @articles = @articles.order("#{params[:order]}": "#{params[:sort]}")
    end
  end
end
