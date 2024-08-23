class ChatGpt < ApplicationRecord
  belongs_to :user

  # 許可されるモードを追加
  MODES = %w[teacher].freeze

  validates :prompt, presence: true
  validates :mode, inclusion: { in: MODES }
end
