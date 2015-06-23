$(document).on("ready, page:change", function() {

  if ($('#live-dashboard').length) {

    listenButtons();
    delegateButton();

    var firebaseUrl = $('body').data('env');
    var myDataRef = new Firebase(firebaseUrl + 'delegates');
    var myVoteRef = new Firebase(firebaseUrl + 'votes');


   myDataRef.on('child_added', function(snapshot) {
      var message = snapshot.val();
      console.log("firebase delegate snapshot")
      // console.log(message)
      if (message.incident === "redelegate") {
        console.log("redelegate")
        console.log("old_root_info")
        appendScore(message.old_rep_root_count, message.old_rep_root_id);
        console.log("new_root_info")
        appendScore(message.new_rep_root_count, message.new_rep_root_id)
        appendVoteStatus();
        appendDelegatedStatus(message.current_user_id);
        nestParticipant(message.current_user_id, message.new_rep_id)
      }
      else if (message.incident === "new delegate") {
        console.log("new delegate")
        console.log("current_user_info")
        appendScore(0, message.current_user_id);
        console.log("new_root_info")
        appendScore(message.root_count, message.root_user_id)
        appendVoteStatus();
        appendDelegatedStatus(message.current_user_id);
        nestParticipant(message.current_user_id, message.new_rep_id)

      }
      else if (message.incident === "undelegate") {
        appendScore(message.old_delegate_count, message.old_delegate_id);
        appendScore(message.current_user_count, message.current_user_id)
        appendVoteStatus();
        appendUndelegatedStatus(message.current_user_id);
        unnestParticipant(message.current_user_id)
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
        message.abstain_count,
        message.current_user_id,
        message.current_user_vote_value
      );
    });
  }

});

var listenButtons = function() {
  voteButton("#yes-button", "yes");
  voteButton("#no-button", "no");
}

var voteButton = function(buttonClass, voteValue) {
  $(".vote-button").on('click', buttonClass, function(e) {
    e.preventDefault();

    var issueId = $(".issues").attr('id').slice(6);
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

var changeVoteDOM = function(participantCount, yesVotes, noVotes, yesPercentage, noPercentage, voteCount, abstainCount, currentUser, currentUserVoteValue ) {
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

  appendVoteStatus(currentUser, currentUserVoteValue)
  appendVoteZone(currentUser, currentUserVoteValue)
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
    var issueId = $(".issues").attr('id').slice(6);
    console.log(issueId)
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
  console.log("count: " + count)
  console.log("id: " + id)

  var target = $('#' + id).children().children(".badge").html(count)
  console.log(target)
};


var nestParticipant = function(current_user_id, new_rep_id) {
  // Moves the delegate under the representative in the dom
  var constituentDomTemplate = $('#' + current_user_id)
  $('#' + new_rep_id).children(".constituents").append(constituentDomTemplate)
};

var appendVoteZone = function(current_user, currentUserVoteValue) {
  // Moves the delegate under the representative in the dom
  var constituentDomTemplate = $('#' + current_user)
  $('.zone-yes').append(constituentDomTemplate)
};


var unnestParticipant = function(current_user_id, new_rep_id) {
  var constituentDomTemplate = $('#' + current_user_id)
  $(".participants").append(constituentDomTemplate)
};

var appendVoteStatus = function(current_user, currentUserVoteValue) {
  console.log("Append Vote " + currentUserVoteValue)
  $('#' + current_user).children().children(".badge").removeClass("abstain")
  $('#' + current_user).children().children(".badge").removeClass("yes")
  $('#' + current_user).children().children(".badge").removeClass("no")
  $('#' + current_user).children().children(".badge").addClass(currentUserVoteValue)
}

var appendDelegatedStatus = function(current_user) {
  $('#' + current_user).removeClass("delegated")
  $('#' + current_user).addClass("delegated")
}

var appendUndelegatedStatus = function(current_user) {
  $('#' + current_user).removeClass("delegated")
}

var newDrawChart = function(yes_votes, no_votes) {
  // console.log("I am the new draw chart!");
  // console.log(yes_votes);
  // console.log(no_votes);

  var ctx = $("#percent-donut").get(0).getContext("2d");

  var data = [
    {
      value: no_votes,
      color:"#F5781E",
      highlight: "#ff9042",
      label: "Red"
    },
    {
      value: yes_votes,
      color: "#3abc95",
      highlight: "#3bcea2",
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



