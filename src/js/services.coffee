angular.module("touristrApp")

.value('API_ENDPOINT', '//localhost:3000')

.factory "Trip", (API_ENDPOINT, $resource) ->
	$resource "#{API_ENDPOINT}/trips/:id", {id: "@id"}, {update: {method: 'PATCH'}}

.factory "TripCandidates", (API_ENDPOINT, $http) ->
	(tripId) ->
		$http
			method: 'GET'
			url: "#{API_ENDPOINT}/trips/#{tripId}/candidates"

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
		$cookieStore.remove('user')
		$location.path('/login')

	return User
