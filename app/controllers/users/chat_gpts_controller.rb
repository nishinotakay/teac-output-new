# app/controllers/users/chat_gpts_controller.rb

module Users
  class ChatGptsController < Users::Base
    before_action :authenticate_user!, except: [:top]
    before_action :set_chatgpt, only: %i[show edit update destroy continue_question]
    before_action :correct_user, only: %i[show edit update destroy continue_question]
    before_action :set_dashboard, only: %i[new create index show]

    include ChatGptsHelper

    def index
      @chatgpts = current_user.chat_gpts.order(created_at: :desc)
    end

    def new
      @chatgpt = ChatGpt.new(content: '')
    end

    def show
      if @chatgpt.nil?
        redirect_to root_path, alert: '指定されたChatGptが見つかりません。'
      else
        @title, @content = extract_title_and_content(@chatgpt.content)
        Rails.logger.debug "質問の内容: #{@chatgpt.content}"
      end
    end

    def create
      @chatgpt = current_user.chat_gpts.build(chatgpt_params)
      @chatgpt.mode = params[:chat_gpt][:mode]

      if @chatgpt.save
        begin
          response = OpenAiService.generate_chat(@chatgpt.prompt, '', '', mode: @chatgpt.mode)
          @chatgpt.update(content: "質問：#{@chatgpt.prompt}\n回答：#{response[:content]}")
          redirect_to users_chat_gpt_path(@chatgpt), notice: '質問が正常に送信されました。'
        rescue StandardError => e
          flash[:alert] = 'AIによるコンテンツの生成に失敗しました。'
          Rails.logger.error "AIによるコンテンツの生成に失敗しました: #{e.message}"
          @chatgpt.errors.add(:base, 'AIによるコンテンツの生成に失敗しました。')
          render :new, status: :internal_server_error
        end
      else
        Rails.logger.debug "ChatGPT Save Errors: #{@chatgpt.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    end

    def continue_question
      @chatgpt = ChatGpt.find_by(id: params[:id])
      if @chatgpt.blank?
        render json: { error: 'ChatGptが見つかりません。' }, status: :not_found
        return
      end

      new_prompt = params[:new_prompt]
      previous_content = @chatgpt.content
      previous_title = OpenAiService.extract_title(previous_content)
      previous_summary = OpenAiService.generate_summary(previous_content)

      begin
        response = OpenAiService.generate_chat(new_prompt, previous_title, previous_content, mode: @chatgpt.mode, summary: previous_summary)
        new_content = "質問：#{new_prompt}\n\n回答：#{response[:content]}"
        @chatgpt.update(content: "#{previous_content}\n\n#{new_content}")

        render json: { content: render_to_string(partial: 'users/chat_gpts/shared/show_content', locals: { chatgpt: @chatgpt, question_number: @chatgpt.id }) }
      rescue StandardError => e
        Rails.logger.error "AIによるコンテンツの生成に失敗しました: #{e.message}"
        render json: { error: 'AIによるコンテンツの生成に失敗しました。' }, status: :unprocessable_entity
      end
    end

    def destroy
      @chatgpt = ChatGpt.find(params[:id])
      if @chatgpt.user == current_user
        @chatgpt.destroy
        redirect_to users_chat_gpts_path, notice: '質問が削除されました。'
      else
        redirect_to users_chat_gpts_path, alert: '削除権限がありません。'
      end
    end

    private

    def chatgpt_params
      params.require(:chat_gpt).permit(:prompt, :mode)
    end

    def set_chatgpt
      @chatgpt = ChatGpt.find_by(id: params[:id])
      @title, @content = extract_title_and_content(@chatgpt&.content)
    end

    def correct_user
      unless @chatgpt && @chatgpt.user == current_user
        redirect_to users_chat_gpts_path, alert: 'アクセス権限がありません。'
      end
    end

    def set_dashboard
      params[:dashboard] ||= 'false'
      @dashboard = params[:dashboard] != 'false'
    end
  end
end
