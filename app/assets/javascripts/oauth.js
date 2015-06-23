$(document).on("ready, page:change", function() {

  $('#google-oauth').on('click', function(e) {
    e.preventDefault();

    var firebaseUrl = $('body').data('env');
    var firebaseRef = new Firebase(firebaseUrl);

    firebaseRef.authWithOAuthPopup("google", function(error, authData) {
      if (error) {
        console.log("Login failed:", error);
      }
      else {
        console.log("Authenticated successfully with payload:", authData);

        var request = $.ajax({
          type: "POST",
          url: "/login",
          data: { email: authData.google.email, imageUrl: authData.google.cachedUserProfile.picture }
        });

        request.done(function(data) {
          console.log("USER SUCCESS!");
        });

        request.fail(function(response) {
          console.log("USER FAIL!");
        });
      }
    }, {
      scope: "email"
    });

  });
});