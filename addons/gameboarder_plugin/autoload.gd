extends Node

const MAX_QUEUE_SIZE = 100
var API_URL: String = ProjectSettings.get_setting("Gameboarder/api_url", "http://127.0.0.1:8000/api")
var http_client: HTTPRequest
var auth
var game
var leaderboard
var player
var score
var save
var timeout = 10.0
var _request_queue: Array = []
var _is_busy: bool = false

func _ready() -> void:
	http_client = HTTPRequest.new()
	add_child(http_client)
	http_client.timeout = timeout 
	http_client.request_completed.connect(_on_request_completed)
	
	auth = load("res://addons/gameboarder_plugin/auth.gd").new()
	game = load("res://addons/gameboarder_plugin/game.gd").new()
	leaderboard = load("res://addons/gameboarder_plugin/leaderboard.gd").new()
	player = load("res://addons/gameboarder_plugin/player.gd").new()
	score = load("res://addons/gameboarder_plugin/score.gd").new()
	save = load("res://addons/gameboarder_plugin/save.gd").new()
	
	auth.setup(self)
	game.setup(self)
	leaderboard.setup(self)
	player.setup(self)
	score.setup(self)
	save.setup(self)

func _make_request(method, endpoint: String, data: Dictionary = {}, callback: Callable = Callable()) -> void:
	if _request_queue.size() >= MAX_QUEUE_SIZE:
		printerr("[GameBoarder] Queue full, dropping request")
		if callback.is_valid():
			callback.call(0, {"error": "Queue overflow"})
		return
	
	var current_token = Global.user.token if Global.user else ""
	_request_queue.append({
		"method": method,
		"endpoint": endpoint,
		"data": data,
		"callback": callback,
		"auth_token": current_token
	})
	_process_next_request()

func _process_next_request() -> void:
	if _is_busy or _request_queue.is_empty():
		return
	
	_is_busy = true
	var req = _request_queue.pop_front()
	
	var url = API_URL + req.endpoint
	var headers = ["Content-Type: application/json"]
	
	if req.auth_token != "":
		headers.append("Authorization: Bearer " + req.auth_token)
	
	var body := ""
	if req.data.size() > 0:
		body = JSON.stringify(req.data)
	
	var err = http_client.request(url, headers, req.method, body)
	if err != OK:
		printerr("[GameBoarder] HTTPRequest failed: ", err)
		if req.callback.is_valid():
			req.callback.call(0, {"error": "HTTPRequest failed", "code": err})
		_is_busy = false
		_process_next_request()
	else:
		http_client.set_meta("callback", req.callback)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var callback: Callable = http_client.get_meta("callback")
	var response: Dictionary = {}
	
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("[GameBoarder] Network error: ", result)
		response = {"error": "Network error", "code": result}
	else:
		if body.size() > 0:
			var parsed = JSON.parse_string(body.get_string_from_utf8())
			if typeof(parsed) == TYPE_DICTIONARY:
				response = _convert_numeric_ids(parsed)
			else:
				response = {"error": "Invalid JSON"}
		elif response_code == 204:
			response = {"success": true}
		else:
			response = {"error": "Empty response body"}
	
	if callback.is_valid():
		callback.call(response_code, response)
	
	_is_busy = false
	_process_next_request()

func _convert_numeric_ids(data):
	var numeric_fields = ["id", "user_id", "game_id", "leaderboard_id", "save_id", "max_save_slots"]
	
	if typeof(data) == TYPE_ARRAY:
		for i in range(data.size()):
			data[i] = _convert_numeric_ids(data[i])
	elif typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			if key in numeric_fields and typeof(data[key]) == TYPE_FLOAT:
				data[key] = int(data[key])
			elif typeof(data[key]) in [TYPE_DICTIONARY, TYPE_ARRAY]:
				data[key] = _convert_numeric_ids(data[key])
	
	return data
