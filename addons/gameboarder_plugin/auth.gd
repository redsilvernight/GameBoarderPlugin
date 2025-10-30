extends RefCounted

var api

func setup(api_instance):
	api = api_instance
	
func register(email: String, name: String, password: String, callback: Callable):
	var data = {
		"name": name,
		"email": email,
		"password": password
	}
	
	api._make_request(HTTPClient.METHOD_POST, "/register", data, callback)

func login(email: String, password: String, callback: Callable):
	var data = {
		"email": email,
		"password": password
	}
	
	api._make_request(HTTPClient.METHOD_POST, "/login", data, callback)

func me(callback):
	api._make_request(HTTPClient.METHOD_GET, "/me", {}, callback)
	
func logout(callback):
	api._make_request(HTTPClient.METHOD_POST, "/logout", {}, callback)

func deleteAccount(user_id, callback):
	api._make_request(HTTPClient.METHOD_DELETE, str("/users/", user_id), {}, callback)
