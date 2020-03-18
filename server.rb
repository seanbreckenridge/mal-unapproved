require 'json'

require 'sinatra'
require 'haml'

# Don't read from the file if it hasn't changed
# since the last time we read the disk
class JsonCache
  attr_reader :filepath, :modtime, :cached_value

  def initialize(filepath)
    unless File.exists?(filepath)
      abort "Filepath passed to cache initialization does't exist"
    end
    @filepath = filepath
    @modtime = get_mod_time
    @cached_value = read_json
  end

  # get the modification time of the file
  def get_mod_time
    File.mtime(@filepath)
  end

  # read the json file
  def read_json
    JSON.load File.new(@filepath)
  end

  # if the file has changed, read from the file
  # else return the cached value
  def get
    if @modtime == File.mtime(@filepath)
      @cached_value
    else
      @cached_value = read_json
    end
  end
end

$server_dir = File.expand_path(File.dirname(__FILE__))
$json_file = File.join($server_dir, "unapproved.json")
$json_info = File.join($server_dir, "unapproved_info.json")
$json_tar = File.join($server_dir, "unapproved.tar.gz")
unless File.exists?($json_file)
  abort "the cache json file, #{$json_file} does not exist"
end
unless File.exists?($json_info)
  abort "the cache info file, #{$json_file} does not exist"
end

$id_cache = JsonCache.new($json_file)
$info_cache = JsonCache.new($json_info)

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
  @parsed_json = $id_cache.get()
  @parsed_info = $info_cache.get()
  @ids = @parsed_json[@json_key].map(&:to_s)
  @info = @parsed_info[@json_key]
  @data = {}
  @ids.each do |i|
    @id_url = "https://myanimelist.net/#{@url_part}/#{i}"
    if @info.has_key?(i)
      @data[i] = @info[i]
    else
      @data[i] = {"name" => @id_url, "type" => "?", "nsfw" => false}
    end
    @data[i]["url"] = @id_url
  end
  [@ids, @data]
end

def file_updated_minutes_ago
  @mins_ago = ((Time.now - File.mtime($json_file)) / 60).round
  "This was updated #{@mins_ago} minute#{@mins_ago == 1 ? "": "s"} ago"
end

def octocat
  @contents =%Q( <a href="https://github.com/seanbreckenridge/mal-unapproved" class="github-corner" aria-label="View source on GitHub"><svg width="80" height="80" viewBox="0 0 250 250" style="fill:#fff; color:#151513; position: absolute; top: 0; border: 0; right: 0;" aria-hidden="true"><path d="M0,0 L115,115 L130,115 L142,142 L250,250 L250,0 Z"></path><path d="M128.3,109.0 C113.8,99.7 119.0,89.6 119.0,89.6 C122.0,82.7 120.5,78.6 120.5,78.6 C119.2,72.0 123.4,76.3 123.4,76.3 C127.3,80.9 125.5,87.3 125.5,87.3 C122.9,97.6 130.6,101.9 134.4,103.2" fill="currentColor" style="transform-origin: 130px 106px;" class="octo-arm"></path><path d="M115.0,115.0 C114.9,115.1 118.7,116.5 119.8,115.4 L133.7,101.6 C136.9,99.2 139.9,98.4 142.2,98.6 C133.8,88.0 127.5,74.4 143.8,58.0 C148.5,53.4 154.0,51.2 159.7,51.0 C160.3,49.4 163.2,43.6 171.4,40.1 C171.4,40.1 176.1,42.5 178.8,56.2 C183.1,58.6 187.2,61.8 190.9,65.4 C194.5,69.0 197.7,73.2 200.1,77.6 C213.8,80.2 216.3,84.9 216.3,84.9 C212.7,93.1 206.9,96.0 205.4,96.6 C205.1,102.4 203.0,107.8 198.3,112.5 C181.9,128.9 168.3,122.5 157.7,114.1 C157.9,116.9 156.7,120.9 152.7,124.9 L141.0,136.5 C139.8,137.7 141.6,141.9 141.8,141.8 Z" fill="currentColor" class="octo-body"></path></svg></a><style>.github-corner:hover .octo-arm{animation:octocat-wave 560ms ease-in-out}@keyframes octocat-wave{0%,100%{transform:rotate(0)}20%,60%{transform:rotate(-25deg)}40%,80%{transform:rotate(10deg)}}@media (max-width:500px){.github-corner:hover .octo-arm{animation:none}.github-corner .octo-arm{animation:octocat-wave 560ms ease-in-out}}</style>
)
  @contents
end

set :haml, :format => :html5
set :public_folder, File.dirname(__FILE__) + "/public"
set :environment, :production
set :port, 5123

def controller(request_type)
  @ids, @data = read_json request_type
  @updated_desc = file_updated_minutes_ago
  return [request_type, @ids, @data, @updated_desc, octocat]
end


get '/' do
  @request_type, @ids, @data, @updated_desc, @octo = controller(:anime)
  haml :index
end

get '/anime' do
  @request_type, @ids, @data, @updated_desc, @octo = controller(:anime)
  haml :index
end

get '/manga' do
  @request_type, @ids, @data, @updated_desc, @octo = controller(:manga)
  haml :index
end

get '/raw' do
  `cd #{$server_dir}; tar cvzf #{$json_tar} unapproved.json unapproved_info.json` 
  send_file($json_tar, :disposition => "attachment", :filename => File.basename($json_tar))
end
