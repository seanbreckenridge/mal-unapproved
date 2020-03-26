### mal-unapproved

A Sinatra website that serves the output of [`mal_id_cache --unapproved json`](https://github.com/seanbreckenridge/mal-id-cache)

Consists of `cache_loop.sh`, which keeps the JSON cache file up to date and the server, which are both run with [forever](https://github.com/foreversd/forever), see [here](https://github.com/seanbreckenridge/vps/blob/master/restart).

##### Install/Run:

After installing `ruby`, `bundle`, and `python3.6+`:

Assumes you have a built [`mal_id_cache`](https://github.com/seanbreckenridge/mal-id-cache). I run that on my server anyways, so you could just set up a script to periodically `git pull` from that repo. Otherwise, run `mal_id_cache --loop` in a separate screen instance.

Host an instance of jikan on port 8000. See [here](https://github.com/jikan-me/jikan-rest#01-installation-prerequisites) for more info.

```
bundle install
pip3 install --user jikanpy requests
./cache_loop.sh once # (run once to build the initial unapproved/name cache)
ruby server.rb
```
