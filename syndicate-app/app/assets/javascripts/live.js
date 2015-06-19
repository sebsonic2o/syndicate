$(document).ready(function() {
  listenButtons();
  // loadParticipants();
  listenParticipants();
  $(".participant-image").mouseenter(function() {
    // debugger
      $(this).parent().siblings(".delegate-button").show();
  })
})

var listenButtons = function() {

  voteButton("#yes-button", "yes");
  voteButton("#no-button", "no");

}

var loadParticipants = function() {

  // $(".abstain-board").append()

}

var listenParticipants = function() {

    // .mouseleave(function() {
    //   $(this).parent().siblings(".delegate-button").hide();
    // })
  }

var voteButton = function(buttonClass, voteValue) {
  $(".button").on('click', buttonClass, function(e) {
    e.preventDefault();

    var issueId = $(".leaderboard").attr('id');
    var url = '/issues/' + issueId + '/vote?value='+voteValue;

    var request = $.ajax({
      type: "PATCH",
      url: url
    });

    request.done(function(data) {
      console.log("SUCCESS!");
      console.log(data);
    });

    request.fail(function(response) {
      console.log("FAIL!");
    });
  });
}



