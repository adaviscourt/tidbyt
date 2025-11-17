load("cache.star", "cache")
load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("random.star", "random")
load("animation.star", "animation")

PLANETS = {
    "Coruscant": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/coruscant.png",
    },
    "Tatooine": {
        "url": "https://raw.githubusercontent.com/adaviscourt/tidbyt/main/starwarsplanets/tatooine.png",
    },
}

def main(config):
    random_index = random.number(0, len(PLANETS) - 1)
    planet = list(PLANETS.keys())[random_index]
    image = http.get(PLANETS[planet]["url"]).body()
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
                    child = render.Text(planet, color="#000000"),
                ),
            ]
        )
    )
