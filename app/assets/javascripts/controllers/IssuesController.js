angular.module('IssueCtrl',[])
    .controller('IssueIndexController',
    ['$scope', '$resource', '$location', '$http','$routeParams', 'Issue',
        function($scope, $resource, $location, $http, $routeParams, Issue) {
        console.log("IssueIndexController")
        $scope.view = function(issueId) {
            $location.path('/issues/' + issueId)
        };

        $scope.issues = Issue.query(function() {
                // Place inside a function to run AFTER promise resolves.
                console.log($scope.issues)
            }); 
        }])

    .controller('IssueShowController',
    ['$scope', '$resource', '$location', '$http','$routeParams', 'Issue',
        function($scope, $resource, $location, $http, $routeParams, Issue) {
            console.log("IssueShowController")
            $scope.issue = Issue.get({ id: $routeParams.id }); //Get a single movie.Issues a GET to /api/movies/:id
            console.log($scope.issue);
        }])

    .controller('IssueCreateController', 
    ['$scope', '$resource', '$location', '$http','$routeParams', 'Issue',
        function($scope, $resource, $location, $http, $routeParams, Issue) {
            console.log("IssueCreateController")
            $scope.issue = new Issue();  //create new Issue instance. Properties will be set via ng-model on UI

            $scope.addIssue = function() { //create a new Issue. Issues a POST to /api/Issues
                $scope.issue.$save(function() {
                    console.log($scope.issue);
                    $location.path('/issues/' + $scope.issue.id)
                });
            };

        }])