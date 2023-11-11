module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # reject_unauthorized_connection unless find_verified_user
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    private

      def find_verified_user
        # self.current_user = User.find_by(id: current_user.id) # env['warden'].user
        if user_data = cookies.encrypted[Rails.application.config.session_options[:key]]['warden.user.user.key']
          user_id = user_data[0]#[0] # ユーザーIDの取得
          User.find_by(id: user_id)
        end
      end
  end
end
