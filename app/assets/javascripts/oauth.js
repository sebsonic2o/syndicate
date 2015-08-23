var controlOAuth = function() {
    console.log("oauth.js");

  $('.google-oauth').on('click', function(e) {
    e.preventDefault();

    firebaseRef.authWithOAuthPopup("google", function(error, authData) {
      if (error) {
        console.log("Login failed:", error);
      }
      else {
        console.log("Authenticated successfully with payload:", authData);

        var request = $.ajax({
          type: "POST",
          url: "/login",
          data: {
            email: authData.google.email,
            imageUrl: authData.google.cachedUserProfile.picture,
            givenName: authData.google.cachedUserProfile.given_name,
            familyName: authData.google.cachedUserProfile.family_name
          }
        });

        request.done(function(data) {
          console.log("USER SUCCESS!");
          console.log(data)
          switchUserProfileDOM(data)
        });

        request.fail(function(response) {
          console.log("USER FAIL!");
        });
      }
    }, {
      scope: "email"
    });

  });
}

var switchUserProfileDOM = function(data) {
  console.log("Updating User Profile Area")
  location.reload();
}
