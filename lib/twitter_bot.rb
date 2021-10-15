# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'twitter'
require 'pry'
require 'journalists'
require 'faraday'
require 'dotenv'
require 'json'

Dotenv.load('.env')

def login_twitter
  Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
end

def streaming_login_twitter
  client = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
end

def tweet(str)
  client = login_twitter

  client.update(str)
end

def choose_random_array_element(arr)
  arr[rand(arr.length)]
end

def random_joke
  joke = Faraday.new('https://www.blagues-api.fr/api/type/global/random',
                     headers: { 'Authorization' => "Bearer #{ENV['BLAGUES_API_BEARER_TOKEN']}" }).get
  body = JSON.parse(joke.body)
  "#{body['joke']}\n#{body['answer']}"
end

def tweet_random_journalists
  5.times do
    journalist = choose_random_array_element(JOURNALISTS_ARRAY)
    joke = random_joke
    tweet("#bonjour_monde !
      \n#{journalist}, voici une blague qui pourrait être sympa dans un article (non)\n#{joke}\n@the_hacking_pro")
  end
end

def fav_bonjour_monde(times, client)
  # client = login_twitter
  tweets = []

  client.search('#bonjour_monde').take(times).collect do |tweet|
    puts "#{tweet.user}: #{tweet.text}"
    tweets << tweet
  end

  client.favorite(tweets)
end

def follow_bonjour_monde(num, client)
  # client = login_twitter
  users = []

  client.search('#bonjour_monde').collect do |tweet|
    if users.length < num && !(users.include?(tweet.user) || tweet.user.screen_name == 'BorisGilles')
      users << tweet.user
    end
  end

  client.follow(users)
end

def fav_and_follow_bonjour_monde(fav_num, follow_num)
  client = login_twitter

  fav_bonjour_monde(fav_num, client)
  follow_bonjour_monde(follow_num, client)
end

def streaming_fav_and_follow
  streaming_client = streaming_login_twitter
  client = login_twitter

  topics = ['#bonjour_monde']
  streaming_client.filter(track: topics.join(",")) do |object|
    if object.is_a?(Twitter::Tweet)
      puts object.text
      client.favorite(object)
      client.follow(object.user)
    end
  end
end

streaming_fav_and_follow

# fav_and_follow_bonjour_monde(50, 30)

# tweet_random_journalists

# p joke = random_joke

# tweet("[Test API Twitter 🤖]\n#{joke}")
