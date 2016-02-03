Parse.Cloud.define("FBRequest", function(request,response) {

	var FBSearchUrl = "https://graph.facebook.com/search";

	var qs = require('qs');
	var FBFinalUrl = FBSearchUrl + '?' + qs.stringify({
		q : "Pizza",
		type : "place",
		center : "37.77493\,\-122.419415",
		distance : 1000,
		// topic_filter : "Restaurant",
		access_token : "579372065561657|9d066921951efb06c79ff6ce023b225c"
	})

	var nearbyRestaurants = [];

	Parse.Cloud.httpRequest({
		url: FBFinalUrl,
	    success: function(httpResponse) {
	        var json = JSON.parse(httpResponse.text);
	        var data = json.data;
	        var count = Object.keys(data).length;
	        for (var i = 0; i < count; i++) {
	        	nearbyRestaurants.push(data[i].id);
	        }
	        response.success(nearbyRestaurants);
	    },
	    error: function(httpResponse) {
	    	console.log("FUCK");
	        response.error(httpResponse.text);
	    }
	});
})

Parse.Cloud.define("IGRequest", function(request,response) {

	var IGSearchUrl = "https://api.instagram.com/v1/locations/search?facebook_places_id=";
	var IGAccessToken = "2719814644.1677ed0.9018f252feea4f3e827e7b287561cc2a";
	var fb_place_id_list = Parse.Cloud.run("FBRequest", {}, {success: function(nearbyRestaurants) {
		var results = [];
		var error = null;

		var max = 4;
		var count = 0;

		for (var i = 0; i < max; i++) {
			if (error) { break; }
			var IGFinalUrl = IGSearchUrl + nearbyRestaurants[i] + "&access_token=" + IGAccessToken;

			Parse.Cloud.httpRequest({
				url: IGFinalUrl,
				success: function(httpResponse) {
					count++;

		        	var json = JSON.parse(httpResponse.text);
		        	var data = json.data;
		        	if (data[0]) {
		        		results.push(data[0].id);
		        	}

		        	if (count == max) {
		        		var imageResults = [];
		        		var img_count = 0;
		        		var error = null;

		        		for (var j = 0; j < results.length; j++) {
		        			if (error) { break; }

			        		var IGMediaUrl = "https://api.instagram.com/v1/locations/";
			        		var IGMediaFinalUrl = IGMediaUrl + results[j] + "/media/recent?access_token=" + IGAccessToken;

			        		Parse.Cloud.httpRequest({
			        			url: IGMediaFinalUrl,
			        			success: function(httpResponse) {
			        				img_count++;

			        				var jsonMedia = JSON.parse(httpResponse.text);
			        				var dataMedia = jsonMedia.data;
			        				var images = 3;
			        				for (var k = 0; k < images; k++) {
			        					imageResults.push(dataMedia[0].images.standard_resolution.url);
			        				}
			        				// imageResults.push(IGMediaFinalUrl);

			        				if (img_count == results.length) {
			        					response.success(imageResults);
			        				}
			        			},
			        			error: function(httpResponse) {
			        				imageResults.push("Media Query Failing");
			        				reponse.error("fuck");
			        				error = true;
			        			}
			        		});
			        	}
		    		}
				},
				error: function(httpResponse) {
					error = true;
					response.error("FUUUUUCK");
				}
			});
		}	
	}});	
})

Parse.Cloud.define("yelpRequest", function(request,response) {

	var webSearchUrl = "http://api.yelp.com/v2/search";

	var qs = require('qs');
	var finalUrl = webSearchUrl + '?' + qs.stringify({
		term : "Restaurant",
		ll : "37.77493\,\-122.419415",
		radius_filter : 10
	});

	var OAuth = require('cloud/oauth').OAuth;
	var consumerKey = '_ENFgrn9biv-89wFNmFyvQ';
	var consumerSecret = 'Xu48w4kriVI5TaLRV-VG0Q8Gbq0'
	var accessToken = '_rNIYVwolwg2taUhWhJ-TIAlJ4laOWqd'
	var accessTokenSecret = 'evLfLSw5Exc8G2Au5yB8qmwlSlA'
	var oa = new OAuth(webSearchUrl, webSearchUrl, consumerKey, consumerSecret, "1.0", null, "HMAC-SHA1");
	oa.setClientOptions({ requestTokenHttpMethod: 'GET' });

	var orderedParameters= oa._prepareParameters(accessToken, accessTokenSecret, 'GET', finalUrl, null);
	var headers= {};
	var authorization = oa._buildAuthorizationHeaders(orderedParameters);
	headers["Authorization"] = authorization;

	var nearbyRestaurants = new Array();

	Parse.Cloud.httpRequest({
    	url: finalUrl,
    	headers: headers,
	    success: function(httpResponse) {
	        var json = JSON.parse(httpResponse.text);
	        var businesses = json.businesses;
	        var count = Object.keys(businesses).length;
	        for (var i = 0; i < count; i++) {
	        	nearbyRestaurants.push(businesses[i].name);
	        }
	        response.success(nearbyRestaurants);
	    },
	    error: function(httpResponse) {
	        response.error(finalUrl + httpResponse.text);
	    }
	});
});