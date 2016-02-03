Parse.Cloud.define("loadDishesNearLocation", function(request,response) {
	var FB = require('cloud/FB');
	var IG = require('cloud/IG');

	FB.facebookPlacesNearLocation(request.params.lat, request.params.lon).then(function (places) {
		return IG.instagramIDsForFacebookIDs(places.map(function (place) {
			return place.id;
		}));
	}).then(function (igIDs) {
		return IG.instagramImagesforIDs(igIDs);
	}).then(function (images) {
		response.success(images);
	});
});

