load("cache.star", "cache")
load("encoding/base64.star", "base64")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/json.star", "json")

API_URL = "https://shouldideploy.today/api?tz=%s"

DEFAULT_LOCATION = json.encode({"timezone": "UTC"})
DEFAULT_DESIGN = "thumbs"

DESIGNS = {
    "thumbs": {
        True: {
            "url": "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f44d.png",
            "color": "#144E00",
        },
        False: {
            "url": "https://emoji.aranja.com/static/emoji-data/img-apple-160/1f44e.png",
            "color": "#B41414",
        },
    },
    "symbols": {
        True: {
            "url": "https://emoji.aranja.com/static/emoji-data/img-apple-160/2705.png",
            "color": "#000000",
        },
        False: {
            "url": "https://emoji.aranja.com/static/emoji-data/img-apple-160/274c.png",
            "color": "#000000",
        },
    },
    "error": {
        "url": "https://emoji.aranja.com/static/emoji-data/img-apple-160/2049-fe0f.png",
        "color": "#000000",
    },
}


def main(config):
    design = config.get("design-choice", DEFAULT_DESIGN)

    location_cfg = config.str("location", DEFAULT_LOCATION)
    location = json.decode(location_cfg)
    timezone = location["timezone"]

    api_url_w_timezone = API_URL % timezone
    resp = http.get(api_url_w_timezone)

    if resp.status_code != 200:
        if "does not exist" in resp.json()["error"]["message"]:
            image_to_use = DESIGNS["error"]["url"]
            color_to_use = DESIGNS["error"]["color"]
            message = "Timezone '%s' is not supported" % timezone
        else:
            fail("shouldideploy.today request failed with status %d", resp.status_code)
    else:
        shouldideploy = resp.json()["shouldideploy"]
        message = resp.json()["message"]

        image_to_use = DESIGNS[design][shouldideploy]["url"]
        color_to_use = DESIGNS[design][shouldideploy]["color"]

    image = http.get(image_to_use).body()

    return render.Root(
        child=render.Box(
            render.Column(
                expanded=True,
                main_align="space_evenly",
                cross_align="center",
                children=[
                    render.Image(
                        width=24,
                        height=24,
                        src=image,
                    ),
                    render.Marquee(
                        width=64,
                        offset_start=32,
                        offset_end=32,
                        child=render.Text(
                            message,
                            font="tom-thumb",
                        ),
                        align="center",
                    ),
                ],
            ),
            color=color_to_use,
        ),
    )


def get_schema():
    return schema.Schema(
        version="1",
        fields=[
            schema.Location(
                id="location",
                name="Location",
                desc="Location for which to determine ideal deployment.",
                icon="locationDot",
            ),
            schema.Dropdown(
                id="design-choice",
                name="Thumbs or Symbols",
                desc="Use thumbs with background color or Symbols with no background color",
                icon="wand-magic-sparkles",
                default="Thumbs",
                options=[
                    schema.Option(
                        display="Thumbs",
                        value="thumbs",
                    ),
                    schema.Option(
                        display="Symbols",
                        value="symbols",
                    ),
                ],
            ),
        ],
    )
