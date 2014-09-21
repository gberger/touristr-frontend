angular.module("touristrApp", ["facebook", "ngRoute", "ngResource", "ngCookies", "ngAutocomplete"])

.config ($routeProvider, $httpProvider, FacebookProvider) ->
	FacebookProvider.setAppId('277783592414721');

	$httpProvider.interceptors.push 'APIInterceptor'

	$routeProvider.when "/login",
		templateUrl: "partials/login.html"
		controller: "LoginCtrl"

	$routeProvider.when '/home',
		redirectTo: '/trips'

	$routeProvider.when "/trips",
		templateUrl: "partials/trips.html"
		controller: "TripsCtrl"

	$routeProvider.when "/trips/new",
		templateUrl: "partials/new_trip.html"
		controller: "NewTripCtrl"

	$routeProvider.when "/trips/:id",
		templateUrl: "partials/edit_trip.html"
		controller: "EditTripCtrl"

	$routeProvider.when "/trips/:id/candidates",
		templateUrl: "partials/trip_candidates.html"
		controller: "TripCandidatesCtrl"

	$routeProvider.when "/trips/:id/matches",
		templateUrl: "partials/trip_matches.html"
		controller: "TripMatchesCtrl"

	$routeProvider.when "/trips/:id/matches/:other_id/messages",
		templateUrl: "partials/trip_match_messages.html"
		controller: "TripMatchMessagesCtrl"

	$routeProvider.otherwise redirectTo: "/home"

.factory 'APIInterceptor', ($q, $rootScope, $location, $injector) ->
	request: (config) ->
		# resolve circular dependency
		User = $injector.get('User')
		config.headers['X-API-Key'] = User.apiKey if User.isLoggedIn
		return config

	responseError: (rejection) ->
		# resolve circular dependency
		User = $injector.get('User')
		switch rejection.status
			when 401
				User.logout()

		$q.reject rejection

.run (User) ->
	User.fromStorage()
