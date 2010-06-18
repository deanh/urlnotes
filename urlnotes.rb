require 'open-uri'
require 'rubygems'
require 'sinatra'
require 'sdbm'

# relational databases are for squares. use a DBM with URLs as 
# keys and the notes about the URLs as values
$data = SDBM.open("urlnotes.dbm")

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end

  # ugly, but honest
  def add_css(html)
    css = <<END_OF_CSS
<style type="text/css">
#overlay { position: fixed; left: 0; top: 0; z-index: 100;
           background-color: black; opacity:0.7; filter:alpha(opacity=70);
           height: 100%; width: 100%; color: #fff; padding: 15px;
}
#trans-form { width: 50%; float: right; }
</style>
END_OF_CSS
    html.sub(/<\/head>/i, "#{css}</head>")
  end

  # see above, RE: ugly
  def add_div(html, url)
    text = $data[url] unless $data[url].nil?
    div = <<END_OF_DIV
<div id="overlay">
  <div id="trans-form">
    <h1>Translation Station</h1>
    <form action="/post">
      <textarea cols="50" rows="20" name="text">#{text}</textarea>
      <input type="hidden" name="url" value="#{url}"></input>
      <input type="submit"></input>
    </form>
  </div>
</div>
END_OF_DIV
     html.sub(/<\/body>/i, "#{div}</body>")
  end

  def generate_html(url)
    out = ''
    open(url) {|f| out = f.read}
    add_div(add_css(out.to_s), url)
  end
end

get '/edit' do
  url = params[:url]
  generate_html(url)
end

get '/post' do
  protected!
  # this data ought to be clensed, but...
  url = params[:url]; text = params[:text]
  $data[url] = text
  redirect "/edit?url=#{url}"
end
