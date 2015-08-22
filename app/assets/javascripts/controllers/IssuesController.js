angular.module('IssueCtrl',[]).controller('IssueController', ['$scope', '$resource', '$http', 'Issue', function($scope, $resource, $http, Issue) {
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