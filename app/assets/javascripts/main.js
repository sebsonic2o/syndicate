$(document).on("ready, page:change", function() {
    console.log("main.js");
  var firebaseUrl = $('body').data('env');

  firebaseRef = new Firebase(firebaseUrl);
  firebaseDelegateRef = firebaseRef.child('delegates');
  firebaseVoteRef = firebaseRef.child('votes');
  firebaseUserRef = firebaseRef.child('users');

  controlOAuth();
  controlLive();
  controlIssues();
});

