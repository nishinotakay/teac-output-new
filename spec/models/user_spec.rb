require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with a name and an email' do
    user = described_class.new(
      email:    'user1@user.com',
      name:     'user1',
      password: 'password'
    )
    expect(user).to be_valid
  end

  it 'is invalid without an email' do
    user = described_class.new(
      email:    nil,
      name:     'user2',
      password: 'password'
    )
    user.valid?
    expect(user.errors[:email]).to include('を入力してください')
  end

  it 'is invalid with a duplicate email address' do
    described_class.create(
      email:    'user1@user.com',
      name:     'user3',
      password: 'password'
    )
    user = described_class.new(
      email:    'user1@user.com',
      name:     'user3',
      password: 'password'
    )
    user.valid?
    expect(user.errors[:email]).to include('はすでに存在します')
  end

  # it "factorybot test" do
  #   user = FactoryBot.create(:user)
  #   expect(user).to be_valid
  # end

  it 'factorybot 2' do
    user = FactoryBot.create(:user, :a)
    expect(user.email).to eq 'email@1.com'
  end
end
