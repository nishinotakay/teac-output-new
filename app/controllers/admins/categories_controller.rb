module Admins
  class CategoriesController < Admins::Base
    before_action :authenticate_admin!
    before_action :set_category, only: %i[show edit update destroy]

    def index
      @categories = Category.all
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admins_categories_path, notice: "カテゴリーを作成しました"
      else
        redirect_to request.referer, alert: "カテゴリーの作成に失敗しました"
      end
    end   

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admins_categories_path, notice: "カテゴリーを更新しました"
      else
        redirect_to request.referer, alert: "カテゴリーの更新に失敗しました"
      end
    end
    
    def destroy
    end

    private

      def category_params
        params.require(:category).permit(:name)
      end

      def set_category
        @category = Category.find(params[:id])
      end
  end
end
