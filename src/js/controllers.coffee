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

.controller "TripsCtrl", ($scope, $location, Trip) ->
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

	lpad = (value, length) ->
		if (value.toString().length < length) then lpad('0' + value, length) else value

	formatDate = (date) ->
		return date+'' if typeof date == 'string'
		"#{date.getFullYear()}-#{lpad(date.getMonth()+1, 2)}-#{lpad(date.getDate(), 2)}"


.controller "NewTripCtrl", ($scope, $location, Trip) ->
	$scope.submitNewTrip = ->
		trip = new Trip()
		trip.city = $scope.newTrip.city
		trip.start_date = $scope.newTrip.startDate
		trip.end_date = $scope.newTrip.endDate
		trip.purpose = $scope.newTrip.purpose
		trip.$save ->
			$location.path '/trips'

.controller "EditTripCtrl", ($scope, $location, Trip, $routeParams) ->
	$scope.trip = Trip.get(id: $routeParams.id)
	$scope.saveTrip = ->
		$scope.trip.$save ->
			$location.path '/trips'

.controller "TripCandidatesCtrl", ($scope, $routeParams, Trip, TripCandidates, $http, API_ENDPOINT) ->
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

.controller "TripMatchesCtrl", ($scope, $routeParams, Trip, TripMatches) ->
	$scope.trip = Trip.get(id: $routeParams.id)
	TripMatches($routeParams.id).success (matches) ->
		$scope.matches = matches

.controller "TripMatchMessagesCtrl", ($scope, $routeParams, Trip) ->
	$scope.trip = Trip.get(id: $routeParams.id)
