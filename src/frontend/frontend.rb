require 'rubygems'
require 'sinatra'
require 'httparty'

$stdout.sync = true
$stderr.sync = true

$etcd_servers = ENV["ETCD_SERVERS"].split(",")

def random_etcd_server
  $etcd_servers.sample
end

def value_url
  "http://" + random_etcd_server + ":4001/v2/keys/frontend"
end

def get_value
  JSON.parse(HTTParty.get(value_url).body)["node"]["value"] rescue ""
end

def set_value(new_value)
  HTTParty.put(value_url, body: "value=#{new_value}")
end

def html_escape(v)
  Rack::Utils.escape_html(v)
end

get '/' do
  <<-HTML
  <!DOCTYPE html>
    <html><body>
      <h1>Etcd Frontend</h1>
      <pre><code>#{html_escape(get_value)}</code></pre>
      <form action="/" method="POST">
        <label>New value:</label>
        <input type="text" name="value"/>
        <input type="submit" value="Change"/>
      </form>
    </body></html>
  HTML
end

post '/' do
  set_value(params[:value])
  redirect '/'
end
