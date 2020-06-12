"""
This caches related information in unapproved_info.json

For each ID, it caches the name, the type (e.g. OVA/TV)
and if the entry is NSFW
"""

import os
import json
import time
from typing import Set

import jikanpy

base_dir = os.path.abspath(os.path.dirname(__file__))
jikan = jikanpy.Jikan("http://localhost:8000/v3/")

id_cache_file = os.path.join(base_dir, "unapproved.json")
info_cache_file = os.path.join(base_dir, "unapproved_info.json")
a_k = "unapproved_anime"
m_k = "unapproved_manga"


# request from jikan, with backoff
# return the name, type, and whether this is sfw/nsfw
def request_jikan(endpoint, _id, retry=0, ex=None):
    if retry >= 5:
        print(ex)
        return None
    try:
        print(f"requesting {endpoint}/{_id}")
        resp = getattr(jikan, endpoint)(_id)
        time.sleep(10)
        nsfw = 12 in [g["mal_id"] for g in resp["genres"]]
        return {
            "name": str(resp["title"]),
            "type": str(resp["type"]),
            "nsfw": nsfw
        }
    except (jikanpy.exceptions.JikanException,
            jikanpy.exceptions.APIException) as jex:
        print("...failed with {}, retrying ({} of 5)".format(
            type(jex).__name__, retry))
        print(jex)
        time.sleep((retry + 1) * 2)
        request_jikan(endpoint, _id, retry + 1, jex)


def main():
    # grab unapproved ID cache
    with open(id_cache_file) as id_f:
        id_cache = json.load(id_f)

    # load previous name/type cache
    if os.path.exists(info_cache_file):
        with open(info_cache_file) as c_f:
            name_cache = json.load(c_f)
    else:
        # default cache if broken
        name_cache = {a_k: {}, m_k: {}}

    for req_type, json_key, name_cache_key in (
        ("anime", "unapproved_anime", a_k),
        ("manga", "unapproved_manga", m_k),
    ):
        # cache new information
        for type_id in id_cache[json_key]:
            id_str = str(type_id)
            if id_str not in name_cache[name_cache_key]:
                response = request_jikan(req_type, type_id)
                if response is not None:  # is None when request fails 5 times
                    name_cache[name_cache_key][id_str] = response

        # remove old information
        current_ids: Set[str] = set(map(str, id_cache[json_key]))
        # print(len(name_cache[name_cache_key].keys()))
        for id_str in list(name_cache[name_cache_key]):
            if id_str not in current_ids:
                del name_cache[name_cache_key][id_str]
        # print(len(name_cache[name_cache_key].keys()))

    with open(info_cache_file, 'w') as c_f:
        json.dump(name_cache, c_f)


if __name__ == "__main__":
    main()
