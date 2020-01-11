require 'json'

require 'sinatra'
require 'haml'

$server_dir = File.expand_path(File.dirname(__FILE__))
$json_file = File.join($server_dir, "unapproved.json")

# Uses $json_file and request_type (an symbol)
# to read the local json cache and return
# a list of urls that are the unapproved entries
def read_json(request_type)
  case request_type
  when :manga
    @json_key = "unapproved_manga"
    @url_part = "manga"
  else
    @json_key = "unapproved_anime"
    @url_part = "anime"
  end
  @parsed_json = JSON.load File.new($json_file)
  @ids = @parsed_json[@json_key]
  @ids.map { |i| "https://myanimelist.net/#{@url_part}/#{i}" }
end

def file_updated_minutes_ago
  @mins_ago = ((Time.now - File.mtime($json_file)) / 60).round
  "This was updated #{@mins_ago} minute#{@mins_ago == 1 ? "": "s"} ago"
end

set :haml, :format => :html5
set :public_folder, "public"

get '/' do
  redirect to('/anime')
end

get '/anime' do
  @request_type = :anime
  @urls = read_json @request_type
  @updated_desc = file_updated_minutes_ago
  haml :index
end

get '/manga' do
  @request_type = :manga
  @urls = read_json @request_type
  @updated_desc = file_updated_minutes_ago
  haml :index
end

get '/raw.json' do
  etag File.read($json_file)  # only re-send when json contents change
  send_file($json_file, :disposition => "attachment", :filename => File.basename($json_file))
end
