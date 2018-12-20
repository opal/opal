require 'sinatra'

cat_image = File.open(File.join(File.dirname(__FILE__), 'cat.png'), 'rb').read

get '/' do
  'Ready!'
end

get '/plain_text' do
  status 200
  headers \
    'Content-Type' => 'text/plain'
  body 'plain text'
end

get '/html' do
  status 200
  headers \
    'Content-Type' => 'text/html; charset=utf-8'
  body '<body>'
end

get '/png' do
  status 200
  headers \
    'Content-Type' => 'image/png'
  body cat_image
end

get '/404' do
  status 404
end

get '/500' do
  status 500
end

get '/last_modified' do
  status 200
  headers \
    'Content-Type' => 'text/plain',
    'Last-Modified' => 'Wed, 21 Oct 2015 07:28:00 GMT'
  body 'Look Ma, I have a Last-Modified header'
end
