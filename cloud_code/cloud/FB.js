exports.facebookPlacesNearLocation = function (lat,lon) {
	var qs = require('qs');
	var FBValidCategories =["restaurant/cafe", "bar"];

	var FBSearchUrl = "https://graph.facebook.com/search?";
	var FBFinalUrl = FBSearchUrl + qs.stringify({
		type : "place",
		center : lat + "\," + lon,
		distance : 1000,
		access_token : "579372065561657|9d066921951efb06c79ff6ce023b225c",
		limit: 1000
	});
	
	return Parse.Cloud.httpRequest({
		url: FBFinalUrl
	}).then(function (httpResponse) {
		var data = JSON.parse(httpResponse.text).data.filter(function (place) {
			return FBValidCategories.indexOf(place.category.toLowerCase()) != -1;
		});
		return Parse.Promise.as(data);
	});
}

exports.restaurantForFacebookPlace = function (place) {
	var Restaurant = Parse.Object.extend("Restaurant");
	var restaurant = new Restaurant();

	// TODO: Verify uniqueness.

	restaurant.set("name", place.name);
	restaurant.set("facebookId", place.id);
	restaurant.set("location", new Parse.GeoPoint({
		latitude: place.location.latitude,
		longitude: place.location.longitude
	}));
	
	return restaurant;
}