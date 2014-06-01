require 'twitter'
require 'pry'
require 'mongoid'

Mongoid.load!("mongoid.yml", :development)

class Adventure
  include Mongoid::Document

  field :user_id
  field :user_name
  field :processed_tweet_ids, type: Array

  def processed? tweet
    return if self.processed_tweet_ids.nil?
    self.processed_tweet_ids.include? tweet.id
  end
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key = "ysUQFWWBpOogARj7iCIUQoI9J"
  config.consumer_secret = "EpKZXVtlEtj2T9V2c9gNGVYUS0nAWfOAiqt2D2dN6G2wwm5MHL"
  config.access_token = "2537886024-o6nNm4BpKuqtWXam0pNyIqrm5i4FIyFlEKDsmpE"
  config.access_token_secret = "RzsqROH0NWHRJAxJmNrUS5DtOODspU4uihSC2mXMSjQZE"
end

def states
  {
    /start/ => "there's an ogre in front of you. run? hide?",
    /run/ => "you're running"
  }
end

def figure_out tweet
  text = tweet.text.dup
  text.slice!("@advnturebot")

  states.each do |key, value|
    if text =~ key
      return value
    end
  end
end

mentions = client.mentions #returns an array of last 20 mentions

mentions.each do |tweet|
  id = tweet.user.id
  if result = figure_out(tweet)
    username = tweet.user.screen_name
    if adventure = Adventure.where(user_id: id).first
      unless adventure.processed? tweet
        if client.update("@#{username} #{result}", in_reply_to_status_id: tweet.id)
          adventure.processed_tweet_ids << tweet.id
          adventure.save
        end
      end
    else
      name = tweet.user.name
      adventure = Adventure.create(user_id: id, user_name: name)
      if client.update("@#{username} #{result}", in_reply_to_status_id: tweet.id)
        adventure.processed_tweet_ids = [tweet.id]
        adventure.save
      end
    end
  end
end

