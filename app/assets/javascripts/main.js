$(document).on("ready, page:change", function() {

  var firebaseUrl = $('body').data('env');

  firebaseRef = new Firebase(firebaseUrl);
  firebaseDelegateRef = firebaseRef.child('delegates');
  firebaseVoteRef = firebaseRef.child('votes');
  firebaseUserRef = firebaseRef.child('users');

  controlOAuth();
  controlLive();
  controlIssues();
});

console.log("main.js");

var app = angular.module('syndicate',[
    'templates',
    'ngRoute',
    'ngResource',
])

app.config(['$routeProvider', function($routeProvider) {

    $routeProvider

        // home page
        .when('/', {
            templateUrl: 'index.html',
            controller: 'StoreController'
        });


}]);

app.factory("Issue", function($resource) {
    return $resource("/issues/:id");
});

app.controller('StoreController', ['$scope', '$resource', '$http', 'Issue', function($scope, $resource, $http, Issue) {
    Issue.query(function(data) {
       $scope.issues = data
        console.log($scope.issues)
    });

    Issue.get({ id: 1}, function(data) {
        $scope.issue = data;
        console.log($scope.issue)
    });

    // Angular AJAX uses $http
    //$http.get('/issues').
    //    success(function(data, status, headers, config) {
    //        $scope.issues = data;
    //        //console.log($scope.issues)
    //
    //    }).
    //    error(function(data, status, headers, config) {
    //        // log error
    //    });
    //console.log($scope.issues)
}]);

var gems = [
    {
        name: "Jade",
        price: 2.96,
        description: 'a rare green gem',
        canPurchase: false,
    },
    {
        name: "Gold",
        price: 2,
        description: 'found in the gold rush',
        canPurchase: true,
    },
    {
        name: "Onyx",
        price: 10.72,
        description: 'black soul',
        canPurchase: false,
    }
];