require "sinatra/base"
require "sinatra/config_file"
require "rack-flash"
require "sinatra/formkeeper"



class VimeoApp < Sinatra::Base
  register Sinatra::FormKeeper
  register Sinatra::ConfigFile
  use Rack::Flash

  configure do
    set :environment, :production
    enable :sessions
    set :session_secret, "Session Secret for shotgun development"
    set :protection, :except => :frame_options
    config_file "config/settings.yml"
  end

  def reverse string
    return string.reverse
  end

  get '/' do

  end

  # Initializer Route
  get '/:key/:secret/:access_token/:access_token_secret/:user_id/:visitor_id/:app_id/:mode' do

    # store all API keys and user data in session hash
    session['ck'] = params[:key];
    session['cs'] = params[:secret];
    session['at'] = params[:access_token];
    session['ats'] = params[:access_token_secret];
    session['user_id'] = params[:user_id].to_s;
    session['visitor_id'] = 'u' + params[:visitor_id].to_s;
    session['app_id'] = 'a' + params[:app_id].to_s;
    session['mode'] = params[:mode]

    # create api session and store it in the session
    session['api_session'] = Vimeo::Advanced::Video.new(
      session['ck'],
      session['cs'],
      :token => session['at'],
      :secret => session['ats']
    );

    if params[:mode] == 'e'
      redirect '/list';
    elsif params[:mode] == 'v'
      redirect '/viewvids';
    end
  end

  get '/viewvids' do
    video = session['api_session']
    #get all vids from vimeo account
    @videos = video.get_all(session['user_id'], {
      :page =>  1,
      :per_page => "50",
      :full_response => "1",
      :sort => "newest"
    });

    # get user videos and app videos
    @userVideos = filter_vids_by_tag @videos['videos']['video'], session[:visitor_id];
    @appVideos = filter_vids_by_tag @userVideos, session[:app_id];
    haml :viewvids
  end

  get '/list' do

    video = session['api_session']
    # @currentPage = params[:page].to_i
    @lastVideo
    @totalVideos = 0

    #set first video of current page`
    # @currentPage == 1 ?  @firstVideo = 1 : @firstVideo = @currentPage * 5 - 4;

    #get all vids from vimeo account
    # @videos = video.get_all(session['user_id'], {
    #   :page => @currentPage,
    #   :per_page => "50",
    #   :full_response => "1",
    #   :sort => "newest"
    # });

    @person = Vimeo::Advanced::Person.new(
      session['ck'],
      session['cs'],
      :token => session['at'],
      :secret => session['ats']
    );

    @person = @person.get_info(session['user_id'])
    numUploads = @person['person']['number_of_uploads'].to_i
    numpages = (numUploads / 50).ceil;

    @ALLTHEVIDEOS = [];
    for i in (1..numpages) do
      vids = video.get_all(session['user_id'], {
        :page => i,
        :per_page => "50",
        :full_response => "1",
        :sort => "newest"
      });

      @ALLTHEVIDEOS.concat vids['videos']['video'];
    end


    # get user videos and app videos
    @userVideos = filter_vids_by_tag @ALLTHEVIDEOS, session[:visitor_id];
    @appVideos = filter_vids_by_tag @userVideos, session[:app_id];
    @appVideos = @appVideos.to_a;


    # give all user vids that intersect with appVideos a class attribute of 'selected'
    @userVideos.each do |vid|
      vid['title'] = vid['title'][0..7] + "..." if vid['title'].length > 15
      if (@appVideos.include? vid)
        vid['class'] = 'selected'
      end
    end

    #set pagination variables
    @totalVideos = @appVideos.length if @appVideos
    # @lastVideo = @totalVideos < 5 ? @totalVideos : @firstVideo.to_i + 4 > @appVideos.length ? @appVideos.length : @firstVideos.to_i + 4;
    # @numPages = (@appVideos.length.to_f / 5).ceil;
    # @appVideos = @appVideos[@firstVideo-1..@lastVideo-1]

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
    redirect '/list';
  end

  get '/delete/:id/:title' do
    video = session['api_session']
    video.delete(params[:id]);
    flash[:notice] = "The Video '#{params[:title]}' has been deleted."
    redirect '/list';
  end

  get '/detach/:id' do
    detach_app_from_video params[:id]
    # video = session['api_session']
    # info = video.get_info(params[:id]);
    # tags = info['video'][0]['tags']['tag'];
    # tags.each do |tag|
    #   video.remove_tag(params[:id], tag['id']) if tag['normalized'] == session['app_id'];
    # end
    # response = video.remove_tag(params[:id], "#{session['app_id']}");
    # return info.to_s
    if session['mode'] == "v"
      redirect '/viewvids'
    else
      flash[:notice] = "Video detached from request."
      redirect '/list';
    end
  end

  get '/attach/:ids/:detachIds' do
    video = session['api_session']

    if params[:ids] != '0'
      vidsToAttach = params[:ids].to_s.split(',');
      vidsToAttach.each do |vidId|
        video.add_tags(vidId, "#{session[:app_id]}")
      end
    end

    if params[:detachIds] != '0'
      vidsToDetach = params[:detachIds].to_s.split(',');
      vidsToDetach.each do |vidId|
        detach_app_from_video(vidId)
      end
    end

    redirect '/list'
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
        redirect "/list"
      else
        flash[:notice] = "Oops, something went wrong. Please try again."
        redirect "/upload"
      end
    end
  end

  def filter_vids_by_tag vids, user_tag
    isUser = false;
    userVids = [];

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

  def detach_app_from_video vidId
    video = session['api_session']
    info = video.get_info(vidId);
    tags = info['video'][0]['tags']['tag'];
    tags.each do |tag|
      video.remove_tag(vidId, tag['id']) if tag['normalized'] == session['app_id'];
    end
  end

end
