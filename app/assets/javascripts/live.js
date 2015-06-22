$(document).on("ready, page:change", function() {
  var myDoughnutChart;

  listenButtons();
  // drawChart();
  delegateButton();

  var firebaseUrl = $('body').data('env');

  var myDataRef = new Firebase(firebaseUrl + 'delegates');
  var myVoteRef = new Firebase(firebaseUrl + 'votes');


 myDataRef.on('child_added', function(snapshot) {
    var message = snapshot.val();
    console.log("firebase delegate snapshot")
    // console.log(message)
    if (message.incident === "redelegate") { 
      appendScore(message.old_delegate_count, message.old_delegate_id);
      appendScore(message.new_delegate_count, message.new_delegate_id)
      appendVoteStatus();
      appendDelegatedStatus(message.current_user_id);
      nestParticipant(message.current_user_id, message.new_delegate_id)
    }
    else if (message.incident === "new delegate") {
      appendScore(0, message.current_user_id);
      appendScore(message.new_delegate_count, message.new_delegate_id)
      appendVoteStatus();
      appendDelegatedStatus(message.current_user_id);
      nestParticipant(message.current_user_id, message.new_delegate_id)
    }
    else if (message.incident === "undelegate") {
      appendScore(message.old_delegate_count, message.old_delegate_id);
      appendScore(message.current_user_count, message.current_user_id)
      appendVoteStatus();
    }
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
    e.stopPropagation();
    e.preventDefault();
    console.log(this)
    var array = []
    array.push(this)
    console.log(array)
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

var appendScore = function(count, id) {
  console.log(id)
  console.log(count)
  var target = $('#' + id).children().children(".badge").html(count)
  console.log(target)
};


var nestParticipant = function(current_user_id, representative_id) {
  // Moves the delegate under the representative in the dom
  var constituentDomTemplate = $('#' + current_user_id)
  $('#' + representative_id).children(".constituents").append(constituentDomTemplate)
};

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



