var FB = require('cloud/FB');
var IG = require('cloud/IG');

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
	var allRestaurants = [];
	var restaurantQuery = new Parse.Query("Restaurant");
	restaurantQuery.containedIn("facebookId", fbPlaces.map(function (place) {
		return place.id;
	}));
	
	var dishQuery = new Parse.Query("Dish");
	
	var flattenedPosts = [].concat.apply([], igPosts);
	dishQuery.containedIn("instagramId", flattenedPosts.map(function (post) {
		return post.id;
	}));
	
	// Query restaurants
	return restaurantQuery.find().then(function (existingRestaurants) {
		var existingRestaurantIds = existingRestaurants.map(function (existingRestaurant) {
			return existingRestaurant.get('facebookId');
		});
		
		// Add any new
		var restaurants = fbPlaces
			.filter(function (place) {
				return existingRestaurantIds.indexOf(place.id) == -1;
			})
			.map(function (place) {
				return FB.restaurantForFacebookPlace(place);
			});
			
		allRestaurants = existingRestaurants.concat(restaurants);
		return Parse.Object.saveAll(restaurants);
	
	// Query dishes
	}).then(function (restuarants) {
		return dishQuery.find();
	}).then(function (existingDishes) {
		var existingDishIds = existingDishes.map(function (existingDish) {
			return existingDish.get('instagramId');
		});
		
		// Add any new
		var allDishes = [];
		fbPlaces.forEach(function (place, index) {
			var postsForPlace = igPosts[index];
			if (postsForPlace.length == 0) { return; }

			var restaurant = allRestaurants.filter(function (restaurant) {
				return restaurant.get('facebookId') == place.id;
			})[0];
			
			var dishes = postsForPlace
				.filter(function (post) {
					return existingDishIds.indexOf(post.id) == -1;
				})
				.map(function (post) {
					return IG.dishForInstagramPost(post, restaurant);
				});
			
			allDishes = allDishes.concat(dishes);
		});
		
		return Parse.Object.saveAll(allDishes);
	});
	
}