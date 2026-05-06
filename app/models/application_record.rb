# frozen_string_literal: true
# 全モデルの基底クラス: ActiveRecord::Base を継承し、全モデル共通の設定を担う

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
