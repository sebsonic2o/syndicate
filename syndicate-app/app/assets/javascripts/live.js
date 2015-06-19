$(document).ready(function() {
  listenButtons();
  // loadParticipants();
  listenParticipants();
  $(".participant-image").mouseenter(function() {
    debugger
      $(this).parent().siblings(".delegate-button").show();
  })
})

var listenButtons = function(){

  $(".button").on('click', "#yes-button", function(e){
    e.preventDefault();
    console.log("YEAH BUDDY")
  })


  $(".button").on('click', "#no-button", function(e){
    e.preventDefault();
    console.log("get out.")
  })

}
var loadParticipants = function() {

  // $(".abstain-board").append()

}

var listenParticipants = function() {

    // .mouseleave(function() {
    //   $(this).parent().siblings(".delegate-button").hide();
    // })
  }



