angular.module('IssueCtrl',[])
    .controller('IssueIndexController',
    ['$scope', '$resource', '$location', '$http','$routeParams', 'Issue',
        function($scope, $resource, $location, $http, $routeParams, Issue) {
        console.log("IssueIndexController")
        //$scope.issues = Issue.query();
        //console.log($scope.issues)

        //$scope.issue = Issue.get({ id: $routeParams.id}, function(data) {
        //    console.log($scope.issue)
        //});
        //
        $scope.view = function(issueId) {
            $location.path('/issues/' + issueId)
        };

        $scope.issues = Issue.query(); //fetch all issues. Issues a GET to /api/issues
            console.log($scope.issues)
        }])

    .controller('IssueShowController',
    ['$scope', '$resource', '$location', '$http','$routeParams', 'Issue',
        function($scope, $resource, $location, $http, $routeParams, Issue) {
            console.log("IssueShowController")
            $scope.issue = Issue.get({ id: $routeParams.id }); //Get a single movie.Issues a GET to /api/movies/:id
            console.log($scope.issue)
        }])





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