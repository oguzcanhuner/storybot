require 'twitter'
require 'pry'

Mongoid.load!("mongoid.yml", :development)

client = Twitter::REST::Client.new do |config|
  config.consumer_key = "FrG3rWF9ozwiSUFEadCcK6g1x"
  config.consumer_secret = "9VAo86mWOHFWd4tq1OOLeSCR3rodf45rS2kS22O8gKP9U7isuk"
  config.access_token = "2537886024-oWvUVY8uVuWgntZqiKv4CXGpuaxyDoDr94PJk1c"
  config.access_token_secret = "rzQv9GkJywbbAi43hLAUDEUTijLcmRjJiaI7MZm31uCV2"
end

mentions = client.mentions #returns an array of last 20 mentions

mentions.each do |mention|
  text = get_text_from(mention)
end

class Game
end

