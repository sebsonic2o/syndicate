$(document).ready(function() {
  listenButtons();
  loadParticipants();
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
var loadParticipants = function(){

  $(".abstain-board").append()

}
