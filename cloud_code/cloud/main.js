// Imports
var FB = require('cloud/clients/FB');
var IG = require('cloud/clients/IG');
var Restaurant = require('cloud/models/Restaurant');
var Dish = require('cloud/models/Dish');

// Feed Loading
Parse.Cloud.define("dishesNearLocation", function (request, response) {
	var exclusionPromises = [
		Parse.User.current().get('likedDishes').query().find(),
		Parse.User.current().get('dislikedDishes').query().find()
	]
	
	Parse.Promise.when(exclusionPromises).then(function (likedDishes, dislikedDishes) {
		var exclusions = likedDishes.concat(dislikedDishes).map(function (dish) {
			return dish.id;
		});
		
		var restaurantQuery = new Parse.Query("Restaurant")
			.withinKilometers("location", new Parse.GeoPoint({
				latitude: request.params.lat,
				longitude: request.params.lon
			}), request.params.dist);
		
		
		var dishQuery = new Parse.Query("Dish")
			.include("restaurant")
			.matchesQuery("restaurant", restaurantQuery)
			.notContainedIn("objectId", exclusions)
			.descending("instagramLikeCount");
		
		dishQuery.find().then(function (dishes) {
			response.success(dishes);
		});
	});
});

// Data Reloading
Parse.Cloud.define("loadDishesNearLocation", function(request, response) {
	Parse.Cloud.useMasterKey();
	
	fetchData(request.params.lat, request.params.lon)
		.then(createEntries)
		.then(function(dishes) {
			response.success(dishes);
		});
});

function fetchData(lat, lon) {
	var facebookPlaces = [];
	
	// Fetch places from FB & IG, then fetch posts
	return FB.facebookPlacesNearLocation(lat, lon).then(function (places) {
		facebookPlaces = places;
		return IG.instagramIDsForFacebookIDs(places.map(function (place) {
			return place.id;
		}));
	}).then(function (igIDs) {
		return IG.instagramPostsforIDs(igIDs);
	}).then(function (posts) {
		return Parse.Promise.as(facebookPlaces, posts);
	});
}

function createEntries(fbPlaces, igPosts) {
	// Build/upsert restaurants
	return Restaurant.allForFacebookPlaces(fbPlaces).then(function (restaurants) {
		// Build/upsert dishes
		return Dish.allForInstagramPosts(igPosts, fbPlaces, restaurants);
	});
}