using Toybox.Time.Gregorian as Greg;
using Toybox.Lang as Lang;

module LogMonkey {

    //! The Logger class provides public APIs to log various types of
    //! messages. Each Logger class is associated with a log level which
    //! is set within the Logger.initialize() function.
    class Logger {

        private var mLogLevel, mLogStream;

        //! Creates a new Logger object.
        //! @param [Toybox::Lang::String] The log level value to log messages through this class to
        //! @param [Toybox::Lang::Object] An object which defines a println(message) function
        (:debug)
        function initialize(logLevel, logStream) {
            mLogLevel = logLevel;
            mLogStream = logStream;
        }

        // An empty version of all functions in this class annotated
        // with the :release tag are included to save memory when an
        // app is compiled in release mode. We will still have the same
        // symbols available in the release build so we won't get symbol
        // not found errors while saving memory.
        (:release)
        function initialize(logLevel, logStream) {
        }

        // The string formats to use when printing log messages
        private static var FORMAT_VARIABLE = "$1$=($2$) $3$";
        private static var FORMAT_LOG_MESSAGE = "(lmf1)[$1$] {$2$} $3$: $4$";
        private static var FORMAT_TIMESTAMP = "$1$-$2$-$3$ $4$:$5$:$6$";

        //! Forms a log message based on the given values.
        //! @param [Toybox::Lang::String] tag The tag to apply to the log message
        //! @param [Toybox::Lang::String] message The message to log
        //! @return [Toybox::Lang::String] A log message matching the format specified by FORMAT_TIMESTAMP
        (:debug)
        private function formLogMessage(tag, message) {
            // Get a timestamp from the system
            var currentTime = Greg.info(Time.now(), Time.FORMAT_SHORT);
            var timestamp = Lang.format(FORMAT_TIMESTAMP, [
                currentTime.month.format("%02u"),
                currentTime.day.format("%02u"),
                currentTime.year.format("%04u"),
                currentTime.hour.format("%02u"),
                currentTime.min.format("%02u"),
                currentTime.sec.format("%02u")
            ]);

            // Form the log message
            return Lang.format(FORMAT_LOG_MESSAGE, [timestamp, mLogLevel, tag, message]);
        }

        (:release)
        private function formLogMessage(tag, message) {
        }

        //! Handles the printing of a log message to the log file
        //! @param [Toybox::Lang::String] tag The tag to apply to the log message
        //! @param [Toybox::Lang::String] message The message to log
        (:debug)
        private function log(tag, message) {
            // Print the log message
            mLogStream.println(formLogMessage(tag, message));
        }

        (:release)
        private function log(tag, message) {
        }

        //! Returns the type string of the given variable. Note, this function
        //! will currently only return names within the Toybox.Lang module. If the
        //! given variable isn't a type defined there then "Object" will be returned.
        //! @param [Toybox::Lang::Object] variable The variable to get the type of
        //! @return [Toybox::Lang::String] The name of the type of the given variable
        (:debug)
        private function getVariableType(variable) {
            // If the given value is null we can't switch on it so perform
            // a null check here. The return value should just be "null".
            if (variable == null) {
                return "null";
            }

            // Switch on the type of the variable and return the variable's
            // class name accordingly.
            switch (variable) {
                case instanceof Lang.Array:
                    return "Array";
                case instanceof Lang.Boolean:
                    return "Boolean";
                case instanceof Lang.Char:
                    return "Char";
                case instanceof Lang.Dictionary:
                    return "Dictionary";
                case instanceof Lang.Double:
                    return "Double";
                case instanceof Lang.Exception:
                    return "Exception";
                case instanceof Lang.Float:
                    return "Float";
                case instanceof Lang.Long:
                    return "Long";
                case instanceof Lang.Method:
                    return "Method";
                case instanceof Lang.Number:
                    return "Number";
                case instanceof Lang.String:
                    return "String";
                case instanceof Lang.Symbol:
                    return "Symbol";
                case instanceof Lang.WeakReference:
                    return "WeakReference";
                default:
                    return "Object";
            }
        }

        (:release)
        private function getVariableType(variable) {
        }

        //! Log the given message under the given tag
        //! @param tag The tag to apply to the log message
        //! @param message The message to log
        (:debug)
        public function logMessage(tag, message) {
            log(tag, message);
        }

        (:release)
        public function logMessage(tag, message) {
        }

        //! Log the given Exception under the given tag
        //! @param tag The tag to apply to the log message
        //! @param exception The Exception to log
        (:debug)
        public function logException(tag, exception) {
            log(tag, exception.getErrorMessage());
            //TODO: Iteratre through stacktrace.
        }

        (:release)
        public function logException(tag, exception) {
        }

        //! Log the given variable's information under the given tag
        //! @param tag The tag to apply to the log message
        //! @param variableName The name of the variable being logged
        //! @param variable The variable to log
        (:debug)
        public function logVariable(tag, variableName, variable) {
            var type = getVariableType(variable);
            var value;
            if (variable == null) {
                value = "null";
            } else {
                value = variable.toString();
            }
            log(tag, Lang.format(FORMAT_VARIABLE, [variableName, type, value]));
        }

        (:release)
        public function logVariable(tag, variableName, variable) {
        }

    }

}
