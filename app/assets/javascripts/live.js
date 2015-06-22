$(document).ready(function() {
  var myDoughnutChart;

  listenButtons();
  // drawChart();
  delegateButton();

  var firebaseUrl = $('body').data('env');

  var myDataRef = new Firebase(firebaseUrl + 'delegates');
  var myVoteRef = new Firebase(firebaseUrl + 'votes');

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
    console.log(message);
    appendScore(message);
    appendVoteStatus();
    appendDelegatedStatus(message.current_user_id);
  });

  myVoteRef.on('child_added', function(snapshot) {
    var message = snapshot.val();
    console.log("firebase vote snapshot");
    console.log(message);
    changeVoteDOM(
      message.participant_count,
      message.yes_votes,
      message.no_votes,
      message.yes_percentage,
      message.no_percentage,
      message.vote_count,
      message.abstain_count
    );
  });

});

var listenButtons = function() {
  voteButton("#yes-button", "yes");
  voteButton("#no-button", "no");
}

var voteButton = function(buttonClass, voteValue) {
  $(".vote-button").on('click', buttonClass, function(e) {
    e.preventDefault();

    var issueId = $(".leaderboard").attr('id');
    var url = '/issues/' + issueId + '/vote?value=' + voteValue;

    var request = $.ajax({
      type: "PATCH",
      url: url
    });

    request.done(function(data) {
      console.log("SUCCESS!");
      console.log(data);

      // changeVoteDOM(data.yes_votes, data.no_votes);
    });

    request.fail(function(response) {
      console.log("FAIL!");
    });
  });
}

var changeVoteDOM = function(participantCount, yesVotes, noVotes, yesPercentage, noPercentage, voteCount, abstainCount) {
  $('#total-participants').html(participantCount);
  $('#yes-votes').html(yesVotes);
  $('#no-votes').html(noVotes);
  $('#yes-percentage').html(yesPercentage);
  $('#no-percentage').html(noPercentage);
  $('#total-votes').html(voteCount);
  $('#abstain').html(abstainCount);

  myDoughnutChart.segments[0].value = noVotes;
  myDoughnutChart.segments[1].value = yesVotes;
  myDoughnutChart.update();
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

var newDrawChart = function(yes_votes, no_votes) {
  // console.log("I am the new draw chart!");
  // console.log(yes_votes);
  // console.log(no_votes);

  var ctx = $("#percent-donut").get(0).getContext("2d");

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
    }
  ];

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
  };

  myDoughnutChart = new Chart(ctx).Doughnut(data,options);
}



