$(document).on("ready, page:change", function() {
  if ($('#live-dashboard').length) {
    //Replace '-' with '/' so date can be parsed by Safari 
    var updatedFinishTime = new Date(finishTime.replace(/-/g, "/"));
    var timeRemaining = (Date.parse(updatedFinishTime) - Date.now());

    if (timeRemaining < 0) {
      var clock = $('.clock').FlipClock(0, {
        countdown: true,
      });
    }
    else {
       var clock = new $('.clock').FlipClock(timeRemaining/1000, {
         countdown: true,
         callbacks: {
           stop: function() {
            closeIssue();
          }
        }
      });
    }

    listenButtons();
    delegateButton();


    var firebaseUrl = $('body').data('env');
    var myDelegateRef = new Firebase(firebaseUrl + 'delegates');
    var myVoteRef = new Firebase(firebaseUrl + 'votes');
    var myUserRef = new Firebase(firebaseUrl + 'users');

    myDelegateRef.on('child_added', function(snapshot) {
      var message = snapshot.val();
      console.log("firebase delegate snapshot")

      if ($('#issue-' + message.issue_id).length) {
        if (message.incident === "redelegate") {
          console.log("redelegate")
          console.log("old_root_info")
          appendScore(message.old_rep_root_count, message.old_rep_root_id);
          console.log("new_root_info")
          appendScore(message.new_rep_root_count, message.new_rep_root_id)
          appendDelegatedStatus(message.current_user_id, message.new_rep_id, message.old_rep_id);
          nestParticipant(message.current_user_id, message.new_rep_id)

        }
        else if (message.incident === "new delegate") {
          console.log("new delegate")
          console.log("current_user_info")
          appendScore(0, message.current_user_id);
          console.log("new_root_info")
          appendScore(message.root_count, message.root_user_id)
          appendDelegatedStatus(message.current_user_id, message.new_rep_id);
          nestParticipant(message.current_user_id, message.new_rep_id)
        }
        else if (message.incident === "undelegate") {
          appendScore(message.old_rep_root_count, message.old_rep_root_id);
          appendScore(message.current_user_count, message.current_user_id)
          appendUndelegatedStatus(message.current_user_id, message.old_rep_id);
          // unnestParticipant(message.current_user_id)
        }
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

    myUserRef.on('child_added', function(snapshot) {
      var message = snapshot.val();
      console.log("firebase user snapshot");
      console.log(message);

      if ($('.dashboard.closed').length === 0 && $('.participant#' + message.id).length === 0) {
        changeUserDOM(message);
      }
    });

  }

    clearErrorsOnClick();
});


var closeIssue = function() {
  var animate = $('.victory').addClass("show animated fadeIn");
  setTimeout(function () {
      $('.dashboard').removeClass("open");
      $('.dashboard').addClass("closed");
  }, 1000)
}

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
  voteButton(".abstain-button", "abstain")
}

var voteButton = function(buttonClass, voteValue) {
  $(".vote-button").on('click', buttonClass, function(e) {
    e.preventDefault();

    var issueId = $(".dashboard").attr('id').slice(6);
    var url = '/issues/' + issueId + '/vote?value=' + voteValue;

    var request = $.ajax({
      type: "PATCH",
      url: url
    });

    request.done(function(data) {
      console.log("SUCCESS!");
      console.log(data);

      if (data.hasOwnProperty('delegated_vote_error')) {
        $('.errors').html(data.delegated_vote_error)
        $('.errors').removeClass("show hide animated fadeIn fadeOut wobble");
        $('html,body').scrollTop(0);
        var animate = $('.errors').addClass("show animated wobble");
        setTimeout(function () {
            animate.addClass("fadeOut");
        }, 2000)
      }

      if (data.hasOwnProperty('log_in_error')) {
        console.log("login error")
        $('.errors').html(data.log_in_error)
        $('html,body').scrollTop(0);
        $('.errors').removeClass("show hide animated fadeIn fadeOut wobble");
        var animate = $('.errors').addClass("show animated wobble");
        setTimeout(function () {
            animate.addClass("fadeOut");
        }, 2000)
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
  // message.current_user_vote_value
  // message.current_user_id

  var drawValues = setDrawValues(message.yes_votes, message.no_votes, message.abstain_count);

  myDoughnutChart.segments[0].value = drawValues.no;
  myDoughnutChart.segments[1].value = drawValues.yes;
  myDoughnutChart.segments[2].value = drawValues.abstain;

  myDoughnutChart.update();
// Move to the correct vote zone
  if (message.move_to_vote_zone == true) {
    moveVoteZone(message.current_user_id, message.current_user_vote_value);
  }
  else {
    console.log("no move");
  }

  // Update the vote count on the users badge
  appendVoteStatus(message.current_user_id, message.current_user_vote_value);
  // Animate the badge
  animateBadge(message.current_user_id);
}

var changeUserDOM = function(message) {
  var participantTemplate =
    '<div id="' + message.id + '" class="participant abstain">\n' +
    '<h3 class="participant-username"><a href="#">' + message.first_name + '</a><em>User ID:' + message.id + '</em></h3>\n' +
    '<div class="participant-avatar">\n' +
    // '<img class="participant-image current" src="' + message.image_url + '" />'
    // '<img class="participant-image rep" src="' + message.image_url + '" />'
    '<img class="participant-image" src="' + message.image_url + '" />\n' +
    '<div class="badge participant-vote-count abstain ">1</div>\n' +
    '</div>\n' +
    '<div class="constituents"></div>\n' +
    '</div>';

    var total = parseInt($('#total-participants').html(), 10) + 1;
    var abstain = parseInt($('#abstain').html(), 10) + 1;

    $('#total-participants').hide();
    $('#total-participants').html(total);
    $('#total-participants').fadeIn(1000);

    $('#abstain').hide();
    $('#abstain').html(abstain);
    $('#abstain').fadeIn(1000);

    $('.zone-abstain .zone-inner').append(participantTemplate).children(':last').hide().fadeIn(1000);
}

var delegateButton = function(){
  $(".participants").on('click', ".participant", function(e){
    clearErrors();
    e.stopPropagation();
    e.preventDefault();
    console.log(this)
    var array = []
    array.push(this)
    console.log(array)
    // When we delegate our vote by clicking on another user they are our "representative"
    var representative = $(this)
    var issueId = $(".dashboard").attr('id').slice(6);
    console.log(issueId)
    var representativeId = $(this).attr('id');
    var url = '/issues/' + issueId + '/users/' + representativeId + '/delegate';

    var request = $.ajax({
      type: "PATCH",
      url: url,
    });

    request.done(function(data) {
      console.log("Ajax - delegate button!");
      console.log(data);
      if (data.hasOwnProperty('hierachy_error')) {
        $('html,body').scrollTop(0);
        $('.errors').html(data.hierachy_error)
        $('.errors').removeClass("show hide animated fadeIn fadeOut wobble");
        var animate = $('.errors').addClass("show animated wobble");
        setTimeout(function () {
            animate.addClass("fadeOut");
        }, 2000)
      }
      if (data.hasOwnProperty('log_in_error')) {
        $('html,body').scrollTop(0);
        $('.errors').html(data.log_in_error)
        $('.errors').removeClass("show hide animated fadeIn fadeOut wobble");
        var animate = $('.errors').addClass("show animated wobble");
        setTimeout(function () {
            animate.addClass("fadeOut");
        }, 2000)
      }
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
  $('#' + new_rep_id).children(".constituents").append(constituentDomTemplate);
  // Animation
  var animate = $('#' + new_rep_id).toggleClass("animated bounceIn");
  setTimeout(function () {
      animate.toggleClass("animated bounceIn");
  }, 2000)
};

var unnestParticipant = function(current_user_id, new_rep_id) {
  console.log("Unest Participants")
  var constituentDomTemplate = $('#' + current_user_id)
  $(".participants").prepend(constituentDomTemplate)
  var animate = $('#' + current_user_id).toggleClass("animated fadeIn");
  setTimeout(function () {
      animate.toggleClass("animated fadeIn");
  }, 2000)
};

var appendVoteStatus = function(current_user, currentUserVoteValue) {
  console.log("Append Vote " + currentUserVoteValue)
  $('#' + current_user).children().children(".badge").removeClass("abstain")
  $('#' + current_user).children().children(".badge").removeClass("yes")
  $('#' + current_user).children().children(".badge").removeClass("no")
  $('#' + current_user).children().children(".badge").addClass(currentUserVoteValue)
};

var appendDelegatedStatus = function(current_user, new_rep_id, old_rep_id) {
  console.log("append delegate status: " + old_rep_id)
  $('#' + current_user).removeClass("delegated")
  $('#' + current_user).addClass("delegated")
  $('#' + new_rep_id).children().children(".participant-image").addClass("rep")
  $('#' + old_rep_id).children().children(".participant-image").removeClass("rep")
  // Adding the delegated class sets the badge to display: none
};

var animateBadge = function(current_user) {
  var animate = $('#' + current_user).children().children(".badge").toggleClass("animated fadeInDown");
  setTimeout(function () {
      animate.toggleClass("animated fadeInDown");
  }, 1000)
};

var appendUndelegatedStatus = function(current_user, old_rep_id) {
  console.log("old_delegate_id: " + old_rep_id)
  $('#' + current_user).removeClass("delegated")
  $('#' + old_rep_id).children().children(".participant-image").removeClass("rep")
}

var moveVoteZone = function(current_user_id, current_user_vote_value) {
  console.log("move zone")
  // Moves the delegate under the representative in the dom
  var constituentDomTemplate = $('#' + current_user_id)
  $('.zone-' + current_user_vote_value + ' .zone-inner').append(constituentDomTemplate)
  var animate = $('#' + current_user_id).toggleClass("animated fadeIn");
  setTimeout(function () {
      animate.toggleClass("animated fadeIn");
  }, 2000)
};


var newDrawChart = function(yesVotes, noVotes, abstainCount) {

  console.log("big doughnut!");

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
