# frozen_string_literal: true

require_relative('../lib/twitter_bot')

describe 'login_twitter method' do
  it 'should return client, and client is not nil' do
    expect(login_twitter).not_to be_nil
  end
end
