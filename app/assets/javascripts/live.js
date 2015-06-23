$(document).on("ready, page:change", function() {

  if ($('#live-dashboard').length) {

    listenButtons();
    delegateButton();
  

    var firebaseUrl = $('body').data('env');
    var myDelegateRef = new Firebase(firebaseUrl + 'delegates');
    var myVoteRef = new Firebase(firebaseUrl + 'votes');


    myDelegateRef.on('child_added', function(snapshot) {
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

      if ($('#issue-' + message.issue_id).length) {
        changeVoteDOM(message);
      }
    });
  }

    clearErrorsOnClick();
});

var clearErrors = function(){
  if ($('#errors').children().length > 0) {
    console.log("Clearing errors div");
    $('#errors').empty();
  }
}

var clearErrorsOnClick = function(){
  $(document).on("click", clearErrors)
}

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

      if (data.hasOwnProperty('error')) {
        $('#errors').append("<p>"+data.error+"</p>")
      }
    });

    request.fail(function(response) {
      console.log("FAIL!");
    });
  });
}

var changeVoteDOM = function(message) {
  $('#total-participants').html(message.participant_count);
  $('#yes-votes').html(message.yes_votes);
  $('#no-votes').html(message.no_votes);
  $('#yes-percentage').html(message.yes_percentage);
  $('#no-percentage').html(message.no_percentage);
  $('#total-votes').html(message.vote_count);
  $('#abstain').html(message.abstain_count);

  var drawValues = setDrawValues(message.yes_votes, message.no_votes, message.abstain_count);

  myDoughnutChart.segments[0].value = drawValues.no;
  myDoughnutChart.segments[1].value = drawValues.yes;
  myDoughnutChart.segments[2].value = drawValues.abstain;

  myDoughnutChart.update();

  appendVoteStatus(message.current_user_id, message.current_user_vote_value);
  // appendVoteZone(message.current_user_id, message.current_user_vote_value);
}

var delegateButton = function(){
  $(".participant").on('click', function(e){
    // if ($('#errors').children().length > 0) {
    //   console.log("Clearing errors div");
    //   $('#errors').empty();
    // }
    clearErrors();
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
  console.log("Getting here!!!!!!")
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

var newDrawChart = function(yesVotes, noVotes, abstainCount) {

  var ctx = $("#percent-donut").get(0).getContext("2d");

  var drawValues = setDrawValues(yesVotes, noVotes, abstainCount);

  var data = [
    {
      value: drawValues.no,
      color: "#F5781E",
      highlight: "#ff9042",
      label: "No"
    },
    {
      value: drawValues.yes,
      color: "#3abc95",
      highlight: "#3bcea2",
      label: "Yes"
    },
    {
      value: drawValues.abstain,
      color: "#C6C6C6",
      highlight: "#D8D8D8",
      label: "Abstain"
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

  myDoughnutChart = new Chart(ctx).Doughnut(data, options);
}

var setDrawValues = function(yesVotes, noVotes, abstainCount) {

  if (noVotes === 0 && yesVotes === 0) {
    return {no: 0, yes: 0, abstain: abstainCount};
  }
  else {
    return {no: noVotes, yes: yesVotes, abstain: 0};
  }
}
