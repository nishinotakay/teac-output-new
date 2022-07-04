# frozen_string_literal: true

module Users
  class DashBoardsController < Users::Base
    def index
      @articles = current_user.articles.all.order(updated_at: "DESC")
    end
  end
end
