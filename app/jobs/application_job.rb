# frozen_string_literal: true
# 全ジョブの基底クラス: ActiveJobを継承し、全バックグラウンドジョブ共通の設定を担う

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
