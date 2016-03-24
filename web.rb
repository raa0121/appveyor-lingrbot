require 'sinatra'
require 'json'
require 'open-uri'
require 'cgi'

$stdout.sync = true

get '/' do
  content_type :text
  "travis-ciのnotificationをLingrに通知するためのBotです。"
end

post '/' do
  ""
end

get '/:room' do
  content_type :text
  "http://lingr.com/room/#{params[:room]} 用のエンドポイントです。\nhttp://lingr.com/bot/travis_ciを部屋に追加してから、.travis.ymlのnotificationのWebHookのurlsに入れると動きます。"
end

post '/:room' do
  content_type :text
  appveyor = JSON.parse(params[:payload])['eventData']
  repo = appveyor['repository']
  status = appveyor['status']
  commit = appveyor['commitMessage']
  build = appveyor['buildUrl']
  if appveyor['isPullRequiest']
    compare = "https://github.com/#{repo}/pull/#{appveyor['pullRequestId']}"
  else
    compare = "https://github.com/#{repo}/commit/#{appveyor['commitId']}"
  end
  text = CGI.escape("[#{repo}#{status}:#{commit}\n#{compare}\n#{build}")
  open("http://lingr.com/api/room/say?room=#{params[:room]}&bot=appveyor&text=#{text}&bot_verifier=").read
end
