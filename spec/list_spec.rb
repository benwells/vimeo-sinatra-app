ENV['RACK_ENV'] = 'test'
require File.dirname(__FILE__) + '/../main.rb'
require 'rspec'
require 'rack/test'

describe 'reverse service' do
  include Rack::Test::Methods

  def app
    VimeoApp
  end

  it "should load home page" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq("")
  end
end
