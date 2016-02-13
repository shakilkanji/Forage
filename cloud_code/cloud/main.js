var FB = require('cloud/clients/FB');
var IG = require('cloud/clients/IG');
var Restaurant = require('cloud/models/Restaurant');
var Dish = require('cloud/models/Dish');

Parse.Cloud.define("loadDishesNearLocation", function(request, response) {
	Parse.Cloud.useMasterKey();
	
	fetchData(request.params.lat, request.params.lon)
		.then(createEntries)
		.then(function(dishes) {
			console.log("4");
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
		console.log("2");
		// Build/upsert dishes
		return Dish.allForInstagramPosts(igPosts, fbPlaces, restaurants);
	});
}