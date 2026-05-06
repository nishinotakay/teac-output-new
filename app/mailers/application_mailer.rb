# frozen_string_literal: true
# 全メーラーの基底クラス: 送信元アドレスとレイアウトを共通設定する

class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
