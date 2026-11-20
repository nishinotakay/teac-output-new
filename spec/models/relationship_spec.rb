# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Relationship do
  let(:tenant) { create(:tenant) }
  let(:follower) { create(:user, tenant: tenant) }
  let(:followed) { create(:user, tenant: tenant) }

  it '同じテナントの別の受講生ならフォローできる' do
    expect(described_class.new(follower: follower, followed: followed)).to be_valid
  end

  it '同じ相手を 2 回フォローすると「すでにフォローしています」で無効になる' do
    described_class.create!(follower: follower, followed: followed)
    relationship = described_class.new(follower: follower, followed: followed)

    expect(relationship).not_to be_valid
    expect(relationship.errors.full_messages).to eq(['すでにフォローしています'])
  end

  it '自分自身をフォローすると「自分自身はフォローできません」で無効になる' do
    relationship = described_class.new(follower: follower, followed: follower)

    expect(relationship).not_to be_valid
    expect(relationship.errors.full_messages).to eq(['自分自身はフォローできません'])
  end

  it '別のテナントの受講生をフォローすると無効になる' do
    other_tenant_user = create(:user, tenant: create(:tenant))
    relationship = described_class.new(follower: follower, followed: other_tenant_user)

    expect(relationship).not_to be_valid
    expect(relationship.errors.full_messages).to eq(['別のスクールの受講生はフォローできません'])
  end
end
