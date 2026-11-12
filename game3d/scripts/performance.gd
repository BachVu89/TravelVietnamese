class_name TravelPerformance
extends RefCounted

## Measures average FPS over short windows so the game can trade visual
## decoration for steadier frame times on slower phones. Gameplay state,
## physics and controls are never touched by this budget.

const SAMPLE_SECONDS := 2.0
const LOW_FPS := 48.0
const SMOOTH_FPS := 57.0

var elapsed := 0.0
var frames := 0
var average_fps := 0.0
var last_low := false

func reset() -> void:
	elapsed = 0.0
	frames = 0
	average_fps = 0.0
	last_low = false

func sample(delta: float) -> bool:
	# Ignore pauses and first-frame spikes so resuming the app cannot trigger a
	# spurious downgrade.
	if delta <= 0.0 or delta >= 0.5:
		return false
	elapsed += delta
	frames += 1
	if elapsed < SAMPLE_SECONDS:
		return false
	average_fps = float(frames) / elapsed
	elapsed = 0.0
	frames = 0
	last_low = average_fps < LOW_FPS
	return last_low

func is_smooth() -> bool:
	return average_fps >= SMOOTH_FPS
