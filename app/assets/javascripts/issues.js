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

var changeIssuesDOM = function(message) {
  var selector = message.issue_id;

  $("#part-" + selector).html("Participants: " + message.participant_count + "  |");
  $("#vote-" + selector).html("Total votes: " + message.vote_count);

  var drawValues = setDrawValues(message.participant_count, message.vote_count);

}
