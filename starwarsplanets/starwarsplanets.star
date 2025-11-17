load("cache.star", "cache")
load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("random.star", "random")
load("animation.star", "animation")

PLANETS = {
    "Alderaan": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/alderaan.png",
        "text_color": "#000000",
    },
    "Bespin": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/bespin.png",
        "text_color": "#000000",
    },
    "Coruscant": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/coruscant.png",
        "text_color": "#000000",
    },
    "That's No Moon": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/deathstar.png",
        "text_color": "#000000",
    },
    "Kashyyyk": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/kashyyyk.png",
        "text_color": "#000000",
    },
    "Korriban": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/korriban.png",
        "text_color": "#000000",
    },
    "Mustafar": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/mustafar.png",
        "text_color": "#000000",
    },
    "Naboo": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/naboo.png",
        "text_color": "#000000",
    },
    "Tatooine": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/tatooine.png",
        "text_color": "#000000",
    },
    "Utapau": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/utapau.png",
        "text_color": "#000000",
    },
    "Yavin": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/yavin.png",
        "text_color": "#000000",
    },
}

def main(config):
    random_index = random.number(0, len(PLANETS) - 1)
    planet = list(PLANETS.keys())[random_index]
    image_url = PLANETS[planet]["url"]
    text_color = PLANETS[planet]["text_color"]
    image = http.get(image_url).body()
    anim = animation.Transformation(
        child = render.Image(src = image, width = 64),
        duration = 120,
        delay = 10,
        direction = "alternate",
        fill_mode = "backwards",
        keyframes = [
            animation.Keyframe(
                percentage = 0.0,
                transforms = [animation.Translate(0, 0)],
                curve = "ease_in_out",
            ),
            animation.Keyframe(
                percentage = 1.0,
                transforms = [animation.Translate(0, -32)],
            ),
        ],
    )
    return render.Root(
        render.Stack(
            children=[
                anim,
                render.Box(
                    child = render.Text(planet, color=text_color),
                ),
            ]
        )
    )
