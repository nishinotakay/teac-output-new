class Api::V1::Admin::CoursesController < Api::V1::BaseController
  before_action :authenticate_admin!

  def index
    courses = Course.order(:id)

    render json: {
      courses: courses.map do |course|
        {
          id: course.id.to_s,
          name: course.name
        }
      end
    }
  end

  def update
    course = Course.find_by(id: params[:id])
    return render_not_found('コース') unless course

    if course.update(name: params[:name])
      head :no_content
    else
      render json: { errors: course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    course = Course.new(name: params[:name])

    if course.save
      # 一覧はフロントから再取得するので、作成したレコードは返さない。
      head :created
    else
      render json: { errors: course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    course = Course.find_by(id: params[:id])
    return render_not_found('コース') unless course
    if course.destroy
      head :no_content
    else
      render json: { errors: course.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
