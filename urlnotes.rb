require 'open-uri'
require 'rubygems'
require 'sinatra'
require 'active_record'
require 'lib/url_note'

configure do
  ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "db/notes.db"
  )  
end

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="URL Notes")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials \
                    && @auth.credentials == ['admin', 'admin']
  end
end

# display a URL with an overlaid form for notes
# i'm trying it the iframe way. it's not quite rad yet.
get '/edit' do
  @url = params[:url] # cleanse this
  @text = if u = UrlNote.find_by_url(@url)
            u.text
          else
            ""
          end
  erb :edit
end

# post notes on a page to the db
post '/post' do
  protected!
  url = params[:url]; text = params[:text] #cleanse this
  unless @note = UrlNote.find_by_url(url)
    @note = UrlNote.new(:url => url)
  end
  @note.text = text
  @note.save
  redirect "#{url}"
end
