
Parse.Cloud.define("loadDishesNearLocation", function(request,response) {
	var FB = require('cloud/FB');
	var IG = require('cloud/IG');

	var facebookPlaces = [];
	var instagramImages = [];
	
	FB.facebookPlacesNearLocation(request.params.lat, request.params.lon).then(function (places) {
		facebookPlaces = places;
		return IG.instagramIDsForFacebookIDs(places.map(function (place) {
			return place.id;
		}));
	}).then(function (igIDs) {
		return IG.instagramImagesforIDs(igIDs);
	}).then(function (images) {
		instagramImages = images;
		var restaurants = facebookPlaces.map(function (place) {
			return FB.restaurantForFacebookPlace(place);
		});

		return Parse.Object.saveAll(restaurants);
	}).then(function (restaurants) {
		console.log('>>> resto ' + JSON.stringify(restaurants));
		console.log('>>> ig img ' + JSON.stringify(instagramImages));
		
		var allDishes = [];
		restaurants.forEach(function (restaurant, index) {
			var imagesForRestaurant = instagramImages[index];
			console.log('>>> img for resto ' + JSON.stringify(imagesForRestaurant));
			var dishes = imagesForRestaurant.map(function (image) {
				return IG.dishForImage(image, restaurant);
			});
	
			console.log('>>> dishes ' + JSON.stringify(dishes));
			allDishes = allDishes.concat(dishes);
		});

		console.log('>>> all dishes ' + JSON.stringify(allDishes));
		return Parse.Object.saveAll(allDishes);
	}).then(function (allDishes) {
		response.success(allDishes);
	});
});