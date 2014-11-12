module.exports = function (grunt) {
    require('load-grunt-tasks')(grunt);
    require('time-grunt')(grunt);
    require('load-grunt-config')(grunt);

    grunt.registerTask('test', [ 'portPick', 'karma' ]);
};