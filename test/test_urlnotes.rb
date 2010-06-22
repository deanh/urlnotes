require 'urlnotes'
require 'test/unit'
require 'rack/test'
#require 'ruby-debug'

set :environment, :test

class UrlNotesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_edit
    get '/edit', :url => 'http://www.google.com'
    assert last_response.ok?
  end

  def test_post_auth
    # no auth
    post '/post'
    assert_equal 401, last_response.status
    # wrong auth
    basic_authorize 'dean', 'foobar'
    assert_equal 401, last_response.status
    # right auth
    basic_authorize 'admin', 'admin'
    post '/post'
    assert_equal 302, last_response.status
  end

  def test_post
    text = 'fooooooo bar'
    # urls are just keys. here's a fake one
    url = 15.times.map {rand(9)}.join 
    basic_authorize 'admin', 'admin'
    post '/post', :url => url, :text => text
    assert_equal 302, last_response.status
    assert un = UrlNote.find_by_url(url)
    assert_equal un.text, text 
    un.delete
  end
end
