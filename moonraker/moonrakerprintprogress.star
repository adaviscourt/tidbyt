"""
Applet: Print Progress
Summary: Print progress bar
desc: Show progress of active print information your moonraker-compatible printer
Author: austindaviscourt
"""

load("animation.star", "animation")
load("humanize.star", "humanize")
load("math.star", "math")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")
load("http.star", "http")
load("encoding/json.star", "json")

API_URL = "http://192.168.0.68"


def main(config):

    active_only = config.bool("active_only", False)

    pd = get_moonraker_status()
    print_time = pd["print_stats"]["print_duration"]
    actual_time = pd["print_stats"]["total_duration"]
    total_time = pd["metadata"].get("estimated_time", 0)
    remaining_time = (total_time - print_time) / 60
    print_progress = pd["display_status"]["progress"]
    speed = pd["gcode_move"]["speed"] / 60
    filename = pd["print_stats"]["filename"].replace(".gcode", "")
    if not filename:
        filename = pd["print_stats"]["state"]
        if active_only:
            return []

    progress_bar_color = get_progress_bar_color(print_progress)
    progress_box_width = 62
    progress_bar_width = min(
        int(math.round(print_progress * progress_box_width)), progress_box_width - 1
    )

    print_progress_str = humanize.float("#,###.#", min(print_progress * 100, 99.9))
    remaining_time_str = humanize.float("#,###.#", remaining_time)
    speed_str = humanize.float("#.", speed)

    progress_bar = None

    if progress_bar_width > 0:
        progress_bar = render.Box(width=progress_bar_width, color=progress_bar_color)

    pulseDuration = (
        3.333 + (30 * print_progress) - (13.333 * math.pow(print_progress, 2))
    )

    pulseAnimation = None
    if pulseDuration > 8.5:
        pulseAnimation = render.Box(
            animation.Transformation(
                child=render.Box(
                    render.Box(
                        render.Box(width=1, height=10, color="#ffffff11"),
                        width=3,
                        height=10,
                        color="#ffffff22",
                    ),
                    width=7,
                    height=10,
                    color="#ffffff22",
                ),
                duration=int(pulseDuration),
                delay=20,
                keyframes=[
                    animation.Keyframe(
                        percentage=0.0,
                        transforms=[animation.Translate(-7, 0)],
                    ),
                    animation.Keyframe(
                        percentage=1,
                        transforms=[animation.Translate(progress_bar_width, 0)],
                    ),
                ],
            ),
            width=progress_bar_width,
        )

    return render.Root(
        render.Column(
            expanded=True,
            children=[
                render.Marquee(
                    width=64,
                    offset_start=32,
                    offset_end=32,
                    child=render.Text(filename, font="6x13", height=11),
                    align="center",
                ),
                render.Box(height=1),
                render.Box(
                    render.Box(
                        render.Stack(
                            children=[
                                render.Row(expanded=True, children=[progress_bar]),
                                pulseAnimation,
                            ],
                        ),
                        width=progress_box_width,
                        height=10,
                        color="#222",
                    ),
                    padding=1,
                    height=12,
                    color="#ccc",
                ),
                render.Box(height=2),
                render.Box(
                    render.Text(
                        "%s%% | %s mm/s"
                        % (
                            print_progress_str,
                            # remaining_time_str,
                            speed_str,
                        ),
                        font="tom-thumb",
                    ),
                    height=7,
                ),
            ],
        ),
    )


def get_schema():
    return schema.Schema(
        version="1",
        fields=[
            schema.Toggle(
                id="active_only",
                name="Display only when actively printing",
                desc="Toggle to hide the app when a print isn't running",
                icon="eyeSlash",
                default=False,
            ),
        ],
    )


def get_moonraker_status():
    api_url = (
        API_URL
        + "/printer/objects/query?gcode_move&toolhead&extruder=target,temperature&display_status&mcu&heaters&system_stats&fan&extruder&heater_bed&print_stats"
    )
    response = http.get(api_url)
    json_data = response.json()["result"]["status"]
    json_data["metadata"] = get_gcode_metadata(json_data["print_stats"]["filename"])
    return json_data


def get_gcode_metadata(gcode_filename):
    api_url = API_URL + "/server/database/item?namespace=gcode_metadata"
    response = http.get(api_url)
    json_data = response.json()["result"]["value"].get(gcode_filename, {})
    return json_data


def get_progress_bar_color(print_progress):
    progress_color_map = {
        "0.0,0.05": "#0d618e",
        "0.05,0.1": "#0f668c",
        "0.1,0.15": "#106c8a",
        "0.15,0.2": "#127289",
        "0.2,0.25": "#147787",
        "0.25,0.3": "#167d85",
        "0.3,0.35": "#188383",
        "0.35,0.4": "#198881",
        "0.4,0.45": "#1b8e7f",
        "0.45,0.5": "#1d947e",
        "0.5,0.55": "#1f997c",
        "0.55,0.6": "#219f7a",
        "0.6,0.65": "#22a478",
        "0.65,0.7": "#24aa76",
        "0.7,0.75": "#26b074",
        "0.75,0.8": "#28b572",
        "0.8,0.85": "#2abb71",
        "0.85,0.9": "#2bc16f",
        "0.9,0.95": "#2dc66d",
        "0.95,1.0": "#2fcc6b",
    }
    found_color_opts = {
        rng: hex
        for rng, hex in progress_color_map.items()
        if (float(rng.split(",")[0]) <= print_progress)
        and (print_progress < float(rng.split(",")[1]))
    }
    if not found_color_opts:
        progress_bar_color = progress_color_map["0.95,1.0"]
    else:
        progress_bar_color = list(found_color_opts.values())[0]
    return progress_bar_color
