require 'sinatra'

get '/' do
  headers \
    'Access-Control-Allow-Origin' => '*'
  'Ready!'
end

get '/plain_text' do
  status 200
  headers(
    'Content-Type' => 'text/plain',
    'Access-Control-Allow-Origin' => '*' )
  body 'plain text'
end


get '/no_header' do
  status 200
  headers(
    'Content-Type' =>  '',
    'Access-Control-Allow-Origin' => '*')
  body 'no header'
end

get '/html' do
  status 200
  headers(
    'Content-Type' => 'text/html; charset=utf-8',
    'Access-Control-Allow-Origin' => '*')
  body '<body>'
end

get '/png' do
  send_file File.join(File.dirname(__FILE__), 'cat.png')
end

get '/404' do
  status 404
  headers \
    'Access-Control-Allow-Origin' => '*'
end

get '/500' do
  status 500
  headers \
    'Access-Control-Allow-Origin' => '*'
end

get '/last_modified' do
  status 200
  headers(
       'Content-Type' => 'text/plain',
       'Last-Modified' => 'Wed, 21 Oct 2015 07:28:00 GMT',
       'Access-Control-Allow-Origin' => '*')
  body 'Look Ma, I have a Last-Modified header'
end

get '/*' do
  status 404
  headers \
    'Access-Control-Allow-Origin' => '*'
end
