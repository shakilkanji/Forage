exports.facebookPlacesNearLocation = function (lat,lon) {
	var qs = require('qs');
	var FBSearchUrl = "https://graph.facebook.com/search?";
	var FBFinalUrl = FBSearchUrl + qs.stringify({
		type : "place",
		center : lat + "\," + lon,
		distance : 1000,
		access_token : "579372065561657|9d066921951efb06c79ff6ce023b225c"
	});

	return Parse.Cloud.httpRequest({
		url: FBFinalUrl
	}).then(function (httpResponse) {
		var data = JSON.parse(httpResponse.text).data;
		return Parse.Promise.as(data);
	});
}

exports.restaurantForFacebookPlace = function (place) {

}