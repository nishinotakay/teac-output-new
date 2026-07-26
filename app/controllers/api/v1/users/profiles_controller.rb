class Api::V1::Users::ProfilesController < Api::V1::BaseController
  before_action :authenticate_user!

  # GET /api/v1/profile
  def show
    profile = @current_user.profile
    if profile
      render json: { profile: profile_json(profile) }
    else
      render json: { profile: nil }
    end
  end

  # PUT /api/v1/profile
  def update
    profile = @current_user.profile || @current_user.build_profile(
      registration_date: Date.today,
      hobby: ''
    )

    if profile.update(profile_params)
      render json: { profile: profile_json(profile) }
    else
      render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.permit(:birthday, :gender, :hobby, :learning_start, :learning_history)
  end

  def profile_json(profile)
    {
      id: profile.id.to_s,
      userId: profile.user_id.to_s,
      birthday: profile.birthday&.strftime('%Y-%m-%d'),
      gender: profile.gender,
      hobby: profile.hobby,
      learningStart: profile.learning_start&.strftime('%Y-%m-%d'),
      learningHistory: profile.learning_history,
      createdAt: profile.created_at.iso8601
    }
  end
end
