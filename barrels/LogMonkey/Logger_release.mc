using Toybox.Time.Gregorian as Greg;
using Toybox.Lang as Lang;

module LogMonkey {

    // An empty version of this class annotated with the :release
    // tag is included to save memory when an app is compiled in
    // release mode. We will still have the same symbols available
    // in the release build so we won't get symbol not found errors
    // while saving memory.
    (:release)
    class Logger {

        function initialize(logLevel, logStream) {
        }

        function logMessage(tag, message) {
        }

        function logException(tag, exception) {
        }

        function logVariable(tag, variableName, variable) {
        }

    }

}
