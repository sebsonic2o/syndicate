$(document).ready(function() {
  listenButtons();
  loadParticipants();
})

var listenButtons = function() {

  $(".button").on('click', "#yes-button", function(e) {
    e.preventDefault();
    console.log("YEAH BUDDY");

    var issueId = $(".vote-board").attr('id');
    var url = '/issues/' + issueId + '/vote?value=yes';

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

  $(".button").on('click', "#no-button", function(e){
    e.preventDefault();
    console.log("get out.");

    var issueId = $(".vote-board").attr('id');
    var url = '/issues/' + issueId + '/vote?value=no';

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

var loadParticipants = function(){

  $(".abstain-board").append()

}
