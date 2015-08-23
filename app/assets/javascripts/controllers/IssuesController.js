angular.module('IssueCtrl',[]).controller('IssueController',
    ['$scope', '$resource', '$location', '$http','$routeParams', 'Issue' , function($scope, $resource, $location, $http, $routeParams, Issue) {

        $scope.issues = Issue.query();

        $scope.issue = Issue.get({ id: $routeParams.id}, function(data) {
            console.log($scope.issue)
        });

        $scope.view = function(issueId) {
            $location.path('/issues/' + issueId)
        };

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