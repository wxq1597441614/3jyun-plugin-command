        var exec = require("cordova/exec");
        function CommandPlugin() {
        }

        CommandPlugin.prototype.init = function (successCallback, errorCallback) {
            exec(
                function(result) {
                    successCallback(result);
                },
                function(error) {
                    errorCallback(error);
                },
                'CommandPlugin',/* "service",*/
                'init',/* "action"*/
                []
            );
        };

        CommandPlugin.prototype.talk = function (successCallback, errorCallback) {
            exec(
                function(result) {
                    successCallback(result);
                },
                function(error) {
                    errorCallback(error);
                },
                'CommandPlugin',/* "service",*/
                'talk',/* "action"*/
                []
            );
        };

        CommandPlugin.prototype.destroy = function (successCallback, errorCallback) {
                    exec(
                        function(result) {
                            successCallback(result);
                        },
                        function(error) {
                            errorCallback(error);
                        },
                        'CommandPlugin',/* "service",*/
                        'destroy',/* "action"*/
                        []
                    );
                };

        var command = new CommandPlugin();
        module.exports = command;


