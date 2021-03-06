exports.instagramIDsForFacebookIDs = function (facebookIDs) {
	var qs = require('qs');
	var IGSearchUrl = "https://api.instagram.com/v1/locations/search?";

	return Parse.Promise.when(facebookIDs.map(function (facebookID) {
		var IGFinalUrl = IGSearchUrl + qs.stringify({
			facebook_places_id : facebookID,
			access_token : "2719814644.1677ed0.9018f252feea4f3e827e7b287561cc2a"
		});

		return Parse.Cloud.httpRequest({
			url: IGFinalUrl
		});
	})).then(function () {
		var httpResponses = [].slice.call(arguments);
		return Parse.Promise.as(httpResponses.map(function (httpResponse) {
			var data = JSON.parse(httpResponse.text).data;
			return data[0].id;
		}));
	});
}

exports.instagramPostsforIDs = function (instagramIDs) {
	var qs = require('qs');
	var IGMediaUrl = "https://api.instagram.com/v1/locations/";
	var IGValidHashtags = [
		"food",
		"foodporn",
		"foodpic",
		"foodinsta",
		"foodinstagram",
		"foodgasm",
		"instafood",
		"foodstagrams",
		"foodphotography",
		"foodstyling",
		"beautifulcuisines",
		"foodlove",
		"foodphoto",
		"igfood"
	];

	return Parse.Promise.when(instagramIDs.map(function (instagramID) {
		var IGFinalUrl = IGMediaUrl + instagramID + "/media/recent?" + qs.stringify({
			access_token : "2719814644.1677ed0.9018f252feea4f3e827e7b287561cc2a"
		});

		return Parse.Cloud.httpRequest({
			url: IGFinalUrl
		});
	})).then(function () {
		var httpResponses = [].slice.call(arguments);
		return Parse.Promise.as(httpResponses.map(function (httpResponse) {
			var data = JSON.parse(httpResponse.text).data;
			if (data.length == 0) {
				return null;
			}

			return data
				.filter(function (igObject) {
					return igObject.tags.filter(function (tag) {
						return IGValidHashtags.indexOf(tag) != -1;
					}).length > 0;
				})
				.map(function (igObject) {
					return igObject;
				});
		}));
	});
}