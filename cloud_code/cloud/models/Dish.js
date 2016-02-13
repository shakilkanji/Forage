var Dish = Parse.Object.extend("Dish", {
  // Initializers
  initialize: function (attrs, options) {
  },
  
  // Accessors
  updated: function () {
    return {
      "photo": this.get("photo"),
      "instagramLikeCount": this.get("instagramLikeCount")
    };
  }
}, {
  // Generators
  forInstagramPost: function (post, restaurant) {
    var dish = new Dish();
    
    dish.set("restaurant", restaurant);
    dish.set("photo", post.images.standard_resolution.url);
    dish.set("instagramId", post.id);
    dish.set("instagramLikeCount", post.likes.count);
    
    return dish;
  },
  
  allForInstagramPosts: function (igPosts, fbPlaces, restaurants) {
    var flattenedPosts = [].concat.apply([], igPosts);
    
    // Prefetch existing dishes
    var existingDishesQuery = new Parse.Query("Dish");
    existingDishesQuery.containedIn("instagramId", flattenedPosts.map(function (post) {
      return post.id;
    }));
    
    return existingDishesQuery.find().then(function (existingDishes) {
      // Build dishes
      var allDishes = [];
      fbPlaces.forEach(function (place, index) {
        var postsForPlace = igPosts[index];
        if (postsForPlace.length == 0) { return; }
      
        var restaurant = restaurants.filter(function (restaurant) {
          return restaurant.get('facebookId') == place.id;
        })[0];
        
        var dishes = postsForPlace.map(function (post) {
          return Dish.forInstagramPost(post, restaurant);
        });
        
        allDishes = allDishes.concat(dishes);
      });
      
      var returnValidDishes = function () {
        var query = new Parse.Query("Dish");
        query.containedIn("instagramId", flattenedPosts.map(function (post) {
          return post.id;
        }));
        
        query.notContainedIn("instagramId", existingDishes.map(function (dish) {
          return dish.get("instagramId");
        }));
        
        console.log("1");
        return query.find();
      };
      
      console.log("3");
      // Upsert dishes
      return Parse.Object.saveAll(allDishes).then(function (dishes) {
        return returnValidDishes();
      }, function (error) {
        return returnValidDishes();
      });
    });
  }
});

// Hooks
Parse.Cloud.beforeSave("Dish", function(request, response) {
  var query = new Parse.Query("Dish");
  query.equalTo("instagramId", request.object.get("instagramId"));
  query.first().then(function (dish) {
    if (dish && dish.id != dish.object.id) {
      dish.save(request.object.updated()).then(function () {
        response.error('Duplicate entry. Existing Dish was updated.');
      });
    } else {
      response.success();
    }
  });
});

module.exports = Dish;