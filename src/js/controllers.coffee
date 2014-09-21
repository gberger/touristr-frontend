angular.module("touristrApp")

.controller "UserCtrl", ($scope, $modal, User) ->
	$scope.user = User

	$scope.logout = ->
		$scope.user.logout()

.controller "LoginCtrl", ($scope, $http, $location, User, Facebook) ->
	$scope.login = ->
		Facebook.login (response) ->
			User.login(response).success ->
				$location.path '/home'

.controller "TripsCtrl", ($scope, $location, Trip, User) ->
	$scope.fetchTrips = ->
		trips = Trip.query ->
			$scope.trips = trips

	$scope.fetchTrips()

	$scope.updateTrip = (trip) ->
		trip.$update().then ->
			$scope.fetchTrips()

	$scope.confirmDelete = (trip) ->
		if confirm('Are you sure you want to delete this trip?')
			trip.$delete ->
				$scope.fetchTrips()

	$scope.newTrip = ->
		$location.path '/trips/new'

	$scope.editTrip = (trip) ->
		$location.path "/trips/#{trip.id}"

	$scope.viewMatches = (trip) ->
		$location.path "/trips/#{trip.id}/matches"

	$scope.viewCandidates = (trip) ->
		$location.path "/trips/#{trip.id}/candidates"

	$scope.logout = ->
		User.logout()

	lpad = (value, length) ->
		if (value.toString().length < length) then lpad('0' + value, length) else value

	formatDate = (date) ->
		return date+'' if typeof date == 'string'
		"#{date.getFullYear()}-#{lpad(date.getMonth()+1, 2)}-#{lpad(date.getDate(), 2)}"


.controller "NewTripCtrl", ($scope, $location, Trip) ->
	$scope.prev = -> $location.path("/trips/")
	$scope.result = ''
	$scope.options = types: '(cities)'
	$scope.details = ''
	$scope.submitNewTrip = ->
		trip = new Trip()
		trip.city = $scope.newTrip.city
		trip.start_date = $scope.newTrip.startDate
		trip.end_date = $scope.newTrip.endDate
		trip.purpose = $scope.newTrip.purpose
		trip.$save ->
			$location.path '/trips'

.controller "EditTripCtrl", ($scope, $location, Trip, $routeParams) ->
	$scope.prev = -> $location.path("/trips/")
	$scope.result = ''
	$scope.options = types: '(cities)'
	$scope.details = ''
	$scope.trip = Trip.get(id: $routeParams.id)
	$scope.saveTrip = ->
		$scope.trip.$update ->
			$location.path '/trips'
	$scope.deleteTrip = ->
		if confirm "Do you really want to delete this trip to #{$scope.trip.city}?"
			$scope.trip.$delete ->
				$location.path '/trips'

.controller "TripCandidatesCtrl", ($scope, $routeParams, $location, Trip, TripCandidates, $http, API_ENDPOINT) ->
	$scope.prev = -> $location.path("/trips/")
	$scope.trip = Trip.get(id: $routeParams.id)
	TripCandidates($routeParams.id).success (candidates) ->
		$scope.candidates = candidates

	$scope.acceptCandidate = ->
		candidate = $scope.candidates[0]
		$scope.candidates = $scope.candidates.slice(1)
		$http(method: 'POST', url: "#{API_ENDPOINT}/trips/#{$scope.trip.id}/candidates/#{candidate.id}/acceptation")

	$scope.rejectCandidate = ->
		candidate = $scope.candidates[0]
		$scope.candidates = $scope.candidates.slice(1)
		$http(method: 'POST', url: "#{API_ENDPOINT}/trips/#{$scope.trip.id}/candidates/#{candidate.id}/rejection")

.controller "TripMatchesCtrl", ($scope, $routeParams, $location, Trip, TripMatches) ->
	$scope.prev = -> $location.path("/trips/")

	$scope.trip = Trip.get(id: $routeParams.id)
	TripMatches($routeParams.id).success (matches) ->
		$scope.matches = matches

	$scope.showMessages = (match) ->
		$location.path("/trips/3/matches/#{match.id}/messages")

.controller "TripMatchMessagesCtrl", ($scope, $routeParams, $location, Trip, TripMatchMessages) ->
	$scope.prev = -> $location.path("/trips/#{$routeParams.id}/matches")

	$scope.trip = Trip.get(id: $routeParams.id)
	$scope.other = Trip.get(id: $routeParams.other_id)

	refresh = ->
		TripMatchMessages.get($routeParams.id, $routeParams.other_id).success (messages) ->
			$scope.messages = messages
	refresh()

	setInterval(refresh, 1000)

	$scope.newMessage = ""
	$scope.sendMessage = ->
		TripMatchMessages.send($routeParams.id, $routeParams.other_id, $scope.newMessage).success ->
			refresh()
		$scope.messages.push({trip_a_id: $routeParams.id, trip_b_id: $routeParams.other_id, msg: $scope.newMessage})
		$scope.newMessage = ""
