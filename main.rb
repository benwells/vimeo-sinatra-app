require 'sinatra'
require 'vimeo'
require 'shotgun'
enable :sessions

get '/:key/:secret/:access_token/:access_token_secret/:user_id' do

  session['ck'] = params[:key];
  session['cs'] = params[:secret];
  session['at'] = params[:access_token];
  session['ats'] = params[:access_token_secret];
  session['uid'] = params[:user_id];
  # base = Vimeo::Advanced::Base.new(consumer_key, consumer_secret, :token => access_token, :secret => access_token_secret)
  # puts base.user_id

  redirect '/list/1';
end

get '/list/:page' do
  # getting and listing videos
  video = Vimeo::Advanced::Video.new(session['ck'],
    session['cs'],
    :token => session['at'],
    :secret => session['ats']);

  @videos = video.get_all(session['uid'], {
    :page => params[:page],
    :per_page => "5",
    :full_response => "1",
    :sort => "newest"
  });

  @videos = @videos['videos']['video']
  erb :index
end

get '/view/:id' do
  @videoId = params[:id];
  @test = session['at'];
  erb :view;
end
