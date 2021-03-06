require 'sinatra'
require 'json'
require 'open-uri'
require 'cgi'

$stdout.sync = true


helpers do
  def protect!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    username = ENV['BASIC_AUTH_USERNAME']
    password = ENV['BASIC_AUTH_PASSWORD']
    p @auth.credentials[0], @auth.credentials[1].chomp, username, password
    p @auth.credentials[0] == username, @auth.credentials[1].chomp == password
    @auth.provided? && @auth.credentials && @auth.credentials[0] == username && @auth.credentials[1].chomp == password
  end
end

get '/' do
  content_type :text
  "AppVeyorのnotificationをLingrに通知するためのBotです。"
end

post '/' do
  ""
end

get '/:room' do
  content_type :text
  "http://lingr.com/room/#{params[:room]} 用のエンドポイントです。\nhttp://lingr.com/bot/AppVeyorを部屋に追加してから、appveyor.ymlのnotificationのWebHookのurlsに入れると動きます。"
end

post '/:room' do
  protect!
  content_type :text
  appveyor = JSON.parse(request.body.read)['eventData']
  p appveyor
  repo = appveyor['repositoryName']
  status = appveyor['status']
  commit = appveyor['commitMessage']
  build = appveyor['buildUrl']
  if appveyor['isPullRequiest']
    compare = "https://github.com/#{repo}/pull/#{appveyor['pullRequestId']}"
  else
    compare = "https://github.com/#{repo}/commit/#{appveyor['commitId']}"
  end
  text = CGI.escape("[#{repo}]#{status}:#{commit}\n#{compare}\n#{build}")
  open("http://lingr.com/api/room/say?room=#{params[:room]}&bot=AppVeyor&text=#{text}&bot_verifier=fad360f1383c91d65a7af1fb56ce8ba6c4cd534b").read
end
