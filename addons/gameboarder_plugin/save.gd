extends RefCounted

var api

func setup(api_instance):
	api = api_instance

func delete(save_id: int, callback: Callable):
	api._make_request(HTTPClient.METHOD_DELETE, str("/saves/", save_id), {}, callback)
