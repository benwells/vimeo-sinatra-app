require 'sinatra'
require 'vimeo'
require 'shotgun'

get '/:key/:secret/:access_token/:access_token_secret/:user_id' do

  consumer_key = params[:key];
  consumer_secret = params[:secret];
  access_token = params[:access_token];
  access_token_secret = params[:access_token_secret];
  user_id = params[:user_id];
  # base = Vimeo::Advanced::Base.new(consumer_key, consumer_secret, :token => access_token, :secret => access_token_secret)
  # puts base.user_id

  # getting and listing videos
  video = Vimeo::Advanced::Video.new(consumer_key,
    consumer_secret,
    :token => access_token,
    :secret => access_token_secret);
    
  @videos = video.get_all(user_id, { :page => "1",
    :per_page => "5",
    :full_response => "1",
    :sort => "newest"
  })
  erb :index
end
