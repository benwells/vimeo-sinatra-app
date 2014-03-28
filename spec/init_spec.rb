ENV['RACK_ENV'] = 'test'
require File.dirname(__FILE__) + '/../main.rb'
require 'rspec'
require 'rack/test'

describe 'initializer route' do
  include Rack::Test::Methods
  def app
    VimeoApp
  end

  def session
    last_request.env['rack.session']
  end

  key = "9438ff2a25cafdcf8e99a1954d1acd8cbdac6868"
  secret = '083f1b7f11e9b0f53850df211c329fc9cc3a661b'
  access_token = "3fc9dc64bcd9a96c3ef4b884d36fa088"
  access_token_secret = "a0f874f903e071057ec6511c44a41b9d7e294080"
  user_id = "user24305088"
  visitor_id = "7704664"
  app_id = "8208981"
  mode = "e"

  # it "should be ok" do
  #   get "/#{key}/#{secret}/#{access_token}/#{access_token_secret}/#{user_id}/#{visitor_id}/#{app_id}/#{mode}"
  #   expect(last_response) be_successful
  # end

  it "saves params in session" do


    get "/#{key}/#{secret}/#{access_token}/#{access_token_secret}/#{user_id}/#{visitor_id}/#{app_id}/#{mode}"

    expect(session[:ck]).to eq("9438ff2a25cafdcf8e99a1954d1acd8cbdac6868")
    expect(session[:cs]).to eq("083f1b7f11e9b0f53850df211c329fc9cc3a661b")
    expect(session[:at]).to eq("3fc9dc64bcd9a96c3ef4b884d36fa088")
    expect(session[:ats]).to eq("a0f874f903e071057ec6511c44a41b9d7e294080")
    expect(session[:user_id]).to eq("user24305088")
    expect(session[:visitor_id]).to eq("u7704664")
    expect(session[:app_id]).to eq("a8208981")
    # expect(params[:mode]).to eq('e')
  end
end
