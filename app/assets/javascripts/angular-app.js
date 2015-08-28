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
            templateUrl: 'issues/index.html',
            controller: 'IssueIndexController'
        }).
        when('/issues', {
            templateUrl: 'issues/index.html',
            controller: 'IssueIndexController'
        }).
        when('/issues/new', {
            templateUrl: 'issues/new.html',
            controller: 'IssueCreateController'
        }).
        when('/issues/:id', {
            templateUrl: 'issues/show.html',
            controller: 'IssueShowController'
        })
        
}]);

