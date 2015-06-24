$(document).on("ready, page:change", function() {

  if ($('#issues-dashboard').length) {
    var firebaseUrl = $('body').data('env');
    var myVoteRef = new Firebase(firebaseUrl + 'votes');

    myVoteRef.on('child_added', function(snapshot) {
      var message = snapshot.val();
      console.log("firebase vote snapshot");
      console.log(message);

      changeIssuesDOM(message);
    });
  };
});

var changeIssuesDOM = function() {

}
