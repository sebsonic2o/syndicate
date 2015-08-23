angular.module('IssueService',[]).factory("Issue", function($resource) {
    return $resource('/api/issues/:id', { id: "@id", format: 'json' });
});