"""
Applet: Print Progress
Summary: Print progress bar
desc: The only progress bar you wish was slower.
Author: chrisbateman
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
DEFAULT_COLOR = "#47a"

def main(config):
    pd = get_moonraker_status()
    print_time = pd["print_stats"]["print_duration"]
    actual_time = pd["print_stats"]["total_duration"]
    total_time = pd["metadata"].get("estimated_time", 0)
    remaining_time = (total_time - print_time) / 60
    print_progress = pd['display_status']['progress']
    filename = pd["print_stats"]["filename"]
    if not filename:
        filename = pd["print_stats"]["state"]

    progress_bar_color = config.get("color", DEFAULT_COLOR)

    progress_box_width = 62
    progress_bar_width = min(int(math.round(print_progress * progress_box_width)), progress_box_width - 1)

    print_progress_str = humanize.float("#,###.#", min(print_progress * 100, 99.9))
    progress_bar = None

    if progress_bar_width > 0:
        progress_bar = render.Box(width = progress_bar_width, color = progress_bar_color)

    pulseDuration = 3.333 + (30 * print_progress) - (13.333 * math.pow(print_progress, 2))

    pulseAnimation = None
    if pulseDuration > 8.5:
        pulseAnimation = render.Box(
            animation.Transformation(
                child = render.Box(
                    render.Box(
                        render.Box(width = 1, height = 10, color = "#ffffff11"),
                        width = 3,
                        height = 10,
                        color = "#ffffff22",
                    ),
                    width = 7,
                    height = 10,
                    color = "#ffffff22",
                ),
                duration = int(pulseDuration),
                delay = 20,
                keyframes = [
                    animation.Keyframe(
                        percentage = 0.0,
                        transforms = [animation.Translate(-7, 0)],
                    ),
                    animation.Keyframe(
                        percentage = 1,
                        transforms = [animation.Translate(progress_bar_width, 0)],
                    ),
                ],
            ),
            width = progress_bar_width,
        )

    return render.Root(
        render.Column(
            expanded = True,
            children = [
                # render.Box(
                #     render.Text(str(filename), font = "6x13"),
                #     height = 11,
                # ),
                render.Marquee(
                    width=64,
                    offset_start=32,
                    offset_end=32,
                    child=render.Text(
                        filename,
                        font="6x13",
                        height=11
                    ),
                    align="center",
                ),
                render.Box(height = 1),
                render.Box(
                    render.Box(
                        render.Stack(
                            children = [
                                render.Row(expanded = True, children = [progress_bar]),
                                pulseAnimation,
                            ],
                        ),
                        width = progress_box_width,
                        height = 10,
                        color = "#222",
                    ),
                    padding = 1,
                    height = 12,
                    color = "#ccc",
                ),
                render.Box(height = 2),
                render.Box(
                    render.Text("%s%% | %s" % (print_progress_str, humanize.float("#,###.#", remaining_time)), font = "tom-thumb"),
                    height = 7,
                ),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Color(
                id = "color",
                name = "Progress bar color",
                desc = "The progress bar fill color",
                icon = "brush",
                default = DEFAULT_COLOR,
            ),
            schema.Toggle(
                id = "milestones_only",
                name = "Display only on milestone days",
                desc = "Every 3-4 days when we hit 1%, 2%, etc.",
                icon = "eyeSlash",
                default = False,
            ),
        ],
    )

def get_moonraker_status():
    api_url = API_URL + "/printer/objects/query?gcode_move&toolhead&extruder=target,temperature&display_status&mcu&heaters&system_stats&fan&extruder&heater_bed&print_stats"
    response = http.get(api_url)
    json_data = response.json()["result"]["status"]
    json_data["metadata"] = get_gcode_metadata(json_data['print_stats']['filename'])
    return json_data


def get_gcode_metadata(gcode_filename):
    api_url = API_URL + "/server/database/item?namespace=gcode_metadata"
    response = http.get(api_url)
    json_data = response.json()["result"]["value"].get(gcode_filename, {})
    return json_data