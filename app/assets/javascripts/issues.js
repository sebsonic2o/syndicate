var controlIssues = function() {

  if ($('#issues-dashboard').length) {
    console.log("issues dashboard fire")

    firebaseVoteRef.on('child_added', function(snapshot) {
      var message = snapshot.val();
      console.log("firebase vote snapshot");
      console.log(message);

      changeIssuesDOM(message);
    });
  };
}

var changeIssuesDOM = function(message) {
  console.log("issues firebase vote snapshot");

  var selector = message.issue_id;

  $("#part-" + selector).html(message.participant_count);
  $("#vote-" + selector).html(message.vote_count);

  var drawValues = setDrawValues(message.yes_votes, message.no_votes, message.abstain_count);


  for (var index = 0; index < doughnutBox.length; index++) {
    if (doughnutBox[index].id === message.issue_id) {
      doughnutBox[index].chart.segments[0].value = drawValues.no;
      doughnutBox[index].chart.segments[1].value = drawValues.yes;
      doughnutBox[index].chart.segments[2].value = drawValues.abstain;
      doughnutBox[index].chart.update();
    }
  }
}

var newLittleDrawChart = function(yesVotes, noVotes, abstainCount, issueId) {

  if (typeof doughnutBox === 'undefined') {
    doughnutBox = [];
  }

  var ctx = $("#little-" + issueId).get(0).getContext("2d");

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
    showTooltips : false,
    segmentShowStroke : false,
    segmentStrokeColor : "#fff",
    segmentStrokeWidth : 0,
    percentageInnerCutout : 50,
    animationSteps : 100,
    animationEasing : "easeOutExpo",
    animateRotate : true,
    animateScale : false,

    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
  };

  doughnutBox.push({ id: issueId, chart: new Chart(ctx).Doughnut(data, options) });
}

var setDrawValues = function(yesVotes, noVotes, abstainCount) {

  if (noVotes === 0 && yesVotes === 0) {
    return {no: 0, yes: 0, abstain: abstainCount};
  }
  else {
    return {no: noVotes, yes: yesVotes, abstain: 0};
  }
}
