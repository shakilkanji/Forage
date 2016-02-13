var Restaurant = Parse.Object.extend("Restaurant", {
  // Initializers
  initialize: function (attrs, options) {
  }
}, {
  // Generators
  forFacebookPlace: function (place) {
    var restaurant = new Restaurant();

    restaurant.set("name", place.name);
    restaurant.set("facebookId", place.id);
    restaurant.set("location", new Parse.GeoPoint({
      latitude: place.location.latitude,
      longitude: place.location.longitude
    }));

    return restaurant;
  },
  
  allForFacebookPlaces: function (places) {    
    var restaurants = places.map(function (place) {
      return Restaurant.forFacebookPlace(place);
    });
    
    var returnValidRestaurants = function () {
      var query = new Parse.Query("Restaurant");
      query.containedIn("facebookId", places.map(function (place) {
        return place.id;
      }));
      
      return query.find();
    };
    
    return Parse.Object.saveAll(restaurants).then(function (restaurants) {
      return returnValidRestaurants();
    }, function (error) {
      return returnValidRestaurants();
    });
  }
});

// Hooks
Parse.Cloud.beforeSave("Restaurant", function(request, response) {
  var query = new Parse.Query("Restaurant");
  query.equalTo("facebookId", request.object.get("facebookId"));
  query.first().then(function (restaurant) {
    if (restaurant && restaurant.id != request.object.id) {
      response.error('Duplicate entry. Existing Restaurant was updated.');
    } else {
      response.success();
    }
  });
});

module.exports = Restaurant;