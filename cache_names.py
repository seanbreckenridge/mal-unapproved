import os
import json
import time

import requests
import jikanpy

base_dir = os.path.abspath(os.path.dirname(__file__))
jikan = jikanpy.Jikan("http://localhost:8000/v3/")

id_cache_file = os.path.join(base_dir, "unapproved.json")
info_cache_file = os.path.join(base_dir, "unapproved_info.json")

a_k = "unapproved_anime"
m_k = "unapproved_manga"

def request_jikan(endpoint, _id, retry=0, ex=None):
    if retry >= 5:
        raise ex
    try:
        print(f"requesting {endpoint}/{_id}")
        resp = getattr(jikan, endpoint)(_id)
        time.sleep(1)
        return {"name": str(resp["title"]), "type": str(resp["type"])}
    except (jikanpy.exceptions.JikanException, jikanpy.exceptions.APIException) as jex:
        print("...failed with {}, retrying ({} of 5)".format(type(jex).__name__, retry))
        time.sleep((retry + 1) * 2)
        request_jikan(endpoint, _id, retry + 1, jex)



def main():
    with open(id_cache_file) as id_f:
        id_cache = json.load(id_f)
        id_cache[a_k] = id_cache[a_k]
    if os.path.exists(info_cache_file):
        with open(info_cache_file) as c_f:
            name_cache = json.load(c_f)
    else:
        name_cache = {a_k: {}, m_k: {}}

    for anime_id in id_cache["unapproved_anime"]:
        id_str = str(anime_id)
        if id_str not in name_cache[a_k]:
            name_cache[a_k][id_str] = request_jikan("anime", anime_id)

    for manga_id in id_cache["unapproved_manga"]:
        id_str = str(manga_id)
        if id_str not in name_cache[m_k]:
            name_cache[m_k][id_str] = request_jikan("manga", manga_id)

    with open(info_cache_file, 'w') as c_f:
        json.dump(name_cache, c_f)

if __name__ == "__main__":
    main()

