
angular.module('IndexCtrl',[]).controller('IndexController',
    ['$scope', '$resource', function($scope, $resource ) {

        console.log("IndexController.js")
        //this.headline = "you can declare it this way without $scope if ya like";
        $scope.headline = 'Headline IndexController';

}]);