### mal-unapproved

A Sinatra website that serves the output of [`mal_id_cache --unapproved json`](https://github.com/seanbreckenridge/mal-id-cache)

Consisnts of `cache_loop.sh`, which keeps the json cache file up to date and the server, which is run with [screen](https://www.gnu.org/software/screen/), see [here](https://github.com/seanbreckenridge/vps/blob/master/restart).

##### Install/Run:

After installing `ruby`/`bundle`:

```
bundle install
pip install --user jikanpy requests
cache_loop.sh
ruby server.rb
```
