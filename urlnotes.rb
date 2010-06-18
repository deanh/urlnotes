require 'open-uri'
require 'rubygems'
require 'sinatra'
require 'sdbm'

# relational databases are for squares. use a DBM with URLs as 
# keys and the notes about the URLs as values
$data = SDBM.open("urlnotes.dbm")

# TODO: this is wrong. i'm not sure how to handle the char encoding
# it needs to be pulled from the read doc. the below handles the 
# ruby-list case
before do
  content_type 'text/html', :charset => 'euc-jp'
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
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end

  # ugly, but honest
  def add_css(html)
    css = <<-END_OF_CSS
      <style type="text/css">
        #overlay { position: fixed; left: 50%; top: 0; z-index: 100;
                   background-color: black; opacity:0.8; 
                   filter:alpha(opacity=80); height: 100%; 
                   width: 50%; color: #fff; padding: 15px;
                   float: right;
        }
        #trans-form { padding: 20px;}
      </style>
    END_OF_CSS
    html.sub(/<\/head>/i, "#{css}</head>")
  end

  # honest, but ugly
  def add_div(html, url)
    text = $data[url] unless $data[url].nil?
    div = <<-END_OF_DIV
    <div id="overlay">
      <div id="trans-form">
        <h1>Translation Station</h1>
        <form action="/post">
          <textarea cols="50" rows="20" name="text">#{text}</textarea>
          <input type="hidden" name="url" value="#{url}"></input>
          <div><input type="submit"></input></div>
        </form>
      </div>
    </div>
    END_OF_DIV
    html.sub(/<\/body>/i, "#{div}</body>")
  end

  # the general plan of attack: grab the html from the url,
  # add in the overlay with the form, send it back to the user
  def generate_html(url)
    out = ''
    open(url) {|f| out = f.read}
    add_div(add_css(out.to_s), url)
  end
end

# display a URL with an overlaid form for notes
get '/edit' do
  url = params[:url]
  generate_html(url)
end

# post notes on a page to the db
get '/post' do
  protected!
  # this data ought to be clensed, but...
  url = params[:url]; text = params[:text]
  $data[url] = text
  redirect "/edit?url=#{url}"
end
