$(document).on("ready, page:change", function() {

  $('#google-oauth').on('click', function(e) {
    e.preventDefault();

    var firebaseUrl = $('body').data('env');
    var firebaseRef = new Firebase(firebaseUrl);

    firebaseRef.authWithOAuthPopup("google", function(error, authData) {
      if (error) {
        console.log("Login failed:", error);
      } else {
        console.log("Authenticated successfully with payload:", authData);
      }
    });

  });
});