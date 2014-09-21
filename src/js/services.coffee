angular.module("touristrApp")

.value("GOOGLE_API_KEY", "AIzaSyAUm_9GDa00zNmVnNLnsbFCRS_pdsQTLVM")

.value('API_ENDPOINT', '//localhost:3000')

.factory "Trip", (API_ENDPOINT, $resource) ->
	$resource "#{API_ENDPOINT}/trips/:id", {id: "@id"}, {update: {method: 'PATCH'}}

.factory "TripCandidates", (API_ENDPOINT, $http) ->
	(tripId) ->
		$http
			method: 'GET'
			url: "#{API_ENDPOINT}/trips/#{tripId}/candidates"

.factory "TripMatches", (API_ENDPOINT, $http) ->
	(tripId) ->
		$http
			method: 'GET'
			url: "#{API_ENDPOINT}/trips/#{tripId}/matches"

.factory "TripMatchMessages", (API_ENDPOINT, $http) ->
	get: (tripId, other_id) ->
		$http
			method: 'GET'
			url: "#{API_ENDPOINT}/trips/#{tripId}/matches/#{other_id}/messages"
	send: (tripId, other_id, message) ->
		$http
			method: 'POST'
			params: {msg: message}
			url: "#{API_ENDPOINT}/trips/#{tripId}/matches/#{other_id}/messages"

.factory "User", (API_ENDPOINT, $http, $location, $cookieStore, Facebook) ->
	User =
		isLoggedIn: false
		name: ''
		apiKey: ''

	User.login = (fbResp) ->
		$http(method: 'POST', url: "#{API_ENDPOINT}/users", params: fbResp.authResponse)
			.success (res) ->
				User.isLoggedIn = true
				User.name = res.name
				User.apiKey = res.api_key
				User.toStorage()

	User.toJSON = ->
		isLoggedIn: @isLoggedIn
		name: @name
		apiKey: @apiKey

	User.fromJSON = (json) ->
		return unless json
		@isLoggedIn = json.isLoggedIn || false
		@name = json.name || ''
		@apiKey = json.apiKey || ''

	User.toStorage = ->
		$cookieStore.put('user', @toJSON())

	User.fromStorage = ->
		@fromJSON($cookieStore.get('user'))

	User.clear = ->
		@isLoggedIn = false
		@name = ''
		@apiKey = ''

	User.logout = ->
		@clear()
		FB.logout()
		$cookieStore.remove('user')
		$location.path('/login')

	return User
