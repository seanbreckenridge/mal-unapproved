### mal-unapproved

Sinatra site that serves the output to [`mal_id_cache --unapproved json`](https://github.com/seanbreckenridge/mal-id-cache)

`cache_loop.sh`, which keeps the json cache file up to date and this server is run with [screen](https://www.gnu.org/software/screen/), see [here](https://github.com/seanbreckenridge/vps).



##### Install/Run:

After installing `ruby`/`bundle`:

```
bundle install
ruby server.rb
```
