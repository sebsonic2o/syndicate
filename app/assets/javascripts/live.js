$(document).ready(function() {
  listenButtons();
  drawChart();
  delegateButton();

  var myDataRef = new Firebase('https://incandescent-heat-2238.firebaseio.com/delegates');

  // $('#messageInput').keypress(function (e) {
  //   if (e.keyCode == 13) {
  //     var name = $('#nameInput').val();
  //     var text = $('#messageInput').val();
  //     myDataRef.push({name: name, text: text});
  //     $('#messageInput').val('');
  //   }
  // });

  myDataRef.on('child_added', function(snapshot) {
    var message = snapshot.val();
    console.log(message)
    appendScore(message);
    appendVoteStatus()
    appendDelegatedStatus(message.current_user_id)
  });

})

var listenButtons = function() {
  voteButton("#yes-button", "yes");
  voteButton("#no-button", "no");
}

var voteButton = function(buttonClass, voteValue) {
  $(".vote-button").on('click', buttonClass, function(e) {
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

var delegateButton = function(){
  $(".participant").on('click', function(e){
    e.preventDefault();
    // When we delegate our vote by clicking on another user they are our "representative"
    var representative = $(this)
    var issueId = $(".leaderboard").attr('id');
    var representativeId = $(this).attr('id');
    var url = '/issues/' + issueId + '/users/' + representativeId + '/delegate';

    var request = $.ajax({
      type: "PATCH",
      url: url,
    });

    request.done(function(data) {
      console.log("Ajax!");
      // console.log(data);
      // participant.children().children(".badge").html(data)
    });

    request.fail(function(response) {
      console.log("FAIL!");
    });


  })
}

var appendScore = function(message) {
  // console.log(target)
  console.log("Firebase Data")
  console.log("current_user_id: " + message.current_user_id)
  console.log("former_representative_id: " + message.former_representative_id)
  console.log("former_representative_vote_count: " + message.former_representative_vote_count)
  console.log("representative_id: " + message.representative_id)
  console.log("representative_vote_count: " + message.representative_vote_count)
  $('#' + message.representative_id).children().children(".badge").html(message.representative_vote_count)
  $('#' + message.former_representative_id).children().children(".badge").html(message.former_representative_vote_count)
}

var appendVoteStatus = function() {
}

var appendDelegatedStatus = function(current_user) {
  $('#' + current_user).removeClass("delegated")
  $('#' + current_user).addClass("delegated")
}


var drawChart = function(){

  console.log("drawChart firing")
  var ctx = $("#percent-donut").get(0).getContext("2d");
  var issueId = $(".leaderboard").attr('id');
  var url = '/issues/' + issueId + '/graph'

  var request = $.ajax({
    type: 'GET',
    url: url,
    success: function (data) {
      var yes_votes = data["yes_votes"]
      var no_votes = data["no_votes"]

      var data = [
        {
          value: no_votes,
          color:"#F7464A",
          highlight: "#FF5A5E",
          label: "Red"
        },
        {
          value: yes_votes,
          color: "#46BFBD",
          highlight: "#5AD3D1",
          label: "Green"
        },
      ]

      var options = {
        segmentShowStroke : true,
        segmentStrokeColor : "#fff",
        segmentStrokeWidth : 2,
        percentageInnerCutout : 50,
        animationSteps : 100,
        animationEasing : "easeOutExpo",
        animateRotate : true,
        animateScale : false,

        legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
      }
      var myDoughnutChart = new Chart(ctx).Doughnut(data,options);
    }
  });
}



