require 'sinatra'
require 'vimeo'
require 'shotgun'
require 'haml'
enable :sessions
set :protection, :except => :frame_options

get '/:key/:secret/:access_token/:access_token_secret/:user_id' do

  session['ck'] = params[:key];
  session['cs'] = params[:secret];
  session['at'] = params[:access_token];
  session['ats'] = params[:access_token_secret];
  session['uid'] = params[:user_id];
  # base = Vimeo::Advanced::Base.new(consumer_key, consumer_secret, :token => access_token, :secret => access_token_secret)
  # puts base.user_id

  session['video'] = Vimeo::Advanced::Video.new(session['ck'],
    session['cs'],
    :token => session['at'],
    :secret => session['ats']);

  redirect '/list/1';
end

get '/list/:page' do
  # getting and listing videos
  video = session['video']
  @currentPage = params[:page].to_i

  if @currentPage == 1
    @firstVideo = 1;
  else
    @firstVideo = @currentPage * 5 - 4;
  end

  @lastVideo = @firstVideo.to_i + 4;

  @totalVideos = video.get_all(session['uid'], {
    :full_response => "0",
    :sort => "newest"
  });
  @totalVideos = @totalVideos['videos']['video'].length

  @numPages = (@totalVideos / 5).ceil;

  @videos = video.get_all(session['uid'], {
    :page => @currentPage,
    :per_page => "5",
    :full_response => "1",
    :sort => "newest"
  });
  @videos = @videos['videos']['video']

  haml :index
end

get '/view/:id' do
  @videoId = params[:id];
  haml :view
end

get '/edit/:id' do
  video = session['video']
  @id = params[:id]
  @info = video.get_info(@id)
  @info = @info['video'][0];

  haml :edit
end

post '/update' do
  video = session['video']
  @title = params["title"]
  @description = params["description"]
  @id = params["vid_id"]
  video.set_description(@id, @description)

  video.set_title(@id, @title);

  # "#{@title} #{@description} #{@id}"
  redirect '/list/1';
end

get '/delete/:id/:title' do
  video = session['video']
  @title = params[:title]
  video.delete(params[:id])
  haml :delete
end

get '/upload' do
  haml :upload
end

post '/upload' do
  upload = Vimeo::Advanced::Upload.new(session['ck'],
    session['cs'],
    :token => session['at'],
    :secret => session['ats']
  );

  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
    # return haml(:upload)
  end
  # while blk = tmpfile.read(65536)
      # File.open(File.join(Dir.pwd,"public/uploads", name), "wb") { |f| f.write(tmpfile.read) }
  # end
 # 'success'
  # aFile = params['vidFile']


  upload.upload(tmpfile);

  "file uploaded!"
end
