console.log("angular-app.js")
var app = angular.module('syndicate',[
    'templates',
    'ngRoute',
    'ngResource',
    'IssueCtrl',
    'IssueService',
    'IndexCtrl',
])

app.config(['$routeProvider', function($routeProvider) {
    $routeProvider
        // home page
        .when('/', {
            templateUrl: 'index.html',
            controller: 'IndexController'
        }).
        when('/issues', {
            templateUrl: 'issues/index.html',
            controller: 'IssueController'
        }).
        when('/issues/:id', {
            templateUrl: 'issues/show.html',
            controller: 'IssueController'
        })
}]);

