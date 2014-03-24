require 'sinatra/base'
require 'rack-flash'

class VimeoApp < Sinatra::Base
  register Sinatra::FormKeeper
  use Rack::Flash

  configure do
    enable :sessions
    set :session_secret, "Session Secret for shotgun development"
    set :protection, :except => :frame_options
  end

  # Initializer Route
  get '/:key/:secret/:access_token/:access_token_secret/:user_id/:visitor_id/:app_id' do

    # store all API keys and user data in session hash
    session['ck'] = params[:key];
    session['cs'] = params[:secret];
    session['at'] = params[:access_token];
    session['ats'] = params[:access_token_secret];
    session['user_id'] = params[:user_id].to_s;
    session['visitor_id'] = 'u' + params[:visitor_id].to_s;
    session['app_id'] = 'a' + params[:app_id].to_s;

    # create api session and store it in the session
    session['api_session'] = Vimeo::Advanced::Video.new(
      session['ck'],
      session['cs'],
      :token => session['at'],
      :secret => session['ats']
    );

    redirect '/list/1';
  end

  get '/list/:page' do

    video = session['api_session']
    @currentPage = params[:page].to_i
    @lastVideo
    @totalVideos = 0

    #set first video of current page`
    @currentPage == 1 ?  @firstVideo = 1 : @firstVideo = @currentPage * 5 - 4;

    #get all vids from vimeo account
    @videos = video.get_all(session['uid'], {
      :page => @currentPage,
      :per_page => "5",
      :full_response => "1",
      :sort => "newest"
    });

    # get user videos and app videos
    @userVideos = filter_vids_by_tag @videos['videos']['video'], session[:visitor_id];
    @appVideos = filter_vids_by_tag @userVideos, session[:app_id];

    #set pagination variables
    @numPages = (@totalVideos / 5).ceil;
    @totalVideos = @appVideos.length if @appVideos
    @lastVideo = @totalVideos < 5 ? @totalVideos : @firstVideo.to_i + 4;

    haml :index
  end

  get '/view/:id' do
    @videoId = params[:id];
    haml :view
  end

  get '/edit/:id' do
    video = session['api_session']
    @id = params[:id]
    @info = video.get_info(@id)
    @info = @info['video'][0];

    haml :edit
  end

  post '/update' do
    video = session['api_session']
    @title = params["title"]
    @description = params["description"]
    @id = params["vid_id"]
    video.set_description(@id, @description)

    video.set_title(@id, @title);

    # "#{@title} #{@description} #{@id}"
    redirect '/list/1';
  end

  get '/delete/:id/:title' do
    video = session['api_session']
    video.delete(params[:id]);
    flash[:notice] = "The Video '#{params[:title]}' has been deleted."
    redirect '/list/1';
  end

  get '/detach/:id' do
    video = session['api_session']
    info = video.get_info(params[:id]);
    tags = info['video'][0]['tags']['tag'];
    tags.each do |tag|
      video.remove_tag(params[:id], tag['id']) if tag['normalized'] == session['app_id'];
    end
    # response = video.remove_tag(params[:id], "#{session['app_id']}");
    flash[:notice] = "Video detached from request."
    # return info.to_s
    redirect '/list/1';
  end

  get '/attach/:ids' do
    video = session['api_session']
    vidIds = params[:ids].to_s.split(',');

    vidIds.each do |vidId|
      video.add_tags(vidId, "#{session[:app_id]}")
    end
    redirect '/list/1'
  end

  get '/upload' do
    haml :upload
  end

  post '/upload' do

    form do
      field :file,   :present => true
    end

    if form.failed?
      flash[:notice] = "You must choose a file."
      redirect '/upload';
    else
      tmpfile = params[:file][:tempfile]
      # name = params[:file][:filename]

      upload = Vimeo::Advanced::Upload.new(session['ck'],
        session['cs'],
        :token => session['at'],
        :secret => session['ats']
      );

      # upload the file
      response = upload.upload(tmpfile);

      if response["stat"] == "ok"
        newVideoId = response['ticket']['video_id']
        video = session['api_session']
        video.set_description(newVideoId, params[:description])
        video.set_title(newVideoId, params[:title])
        video.add_tags(newVideoId, "#{session[:visitor_id]}, #{session[:app_id]}")
        flash[:notice] = "Video Uploaded Successfully."
        redirect "/list/1"
      else
        flash[:notice] = "Oops, something went wrong. Please try again."
        redirect "/upload"
      end
    end
  end

  def filter_vids_by_tag vids, user_tag
    isUser = false;
    userVids = [];
    vids = vids.to_a

    vids.each_with_index do |vid, i|
      isUser = false;
      if vid['tags']
        vid['tags']['tag'].each do |tag|
          isUser = true if tag['normalized'] == user_tag
        end
        userVids.push(vids[i]) if isUser == true
      end
    end
    return userVids
  end

end
