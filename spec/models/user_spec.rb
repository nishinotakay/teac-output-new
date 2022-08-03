require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a name and an email" do
    user = User.new(
      email: "user1@user.com",
      name: "user1",
      password: "password"
    )
    expect(user).to be_valid
  end

  it "is invalid without an email" do
    user = User.new(
      email: nil,
      name: "user2",
      password: "password"
    )
    user.valid?
    expect(user.errors[:email]).to include("を入力してください")
  end
end
