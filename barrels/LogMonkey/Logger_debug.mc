using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;
using Toybox.Lang as Lang;

module LogMonkey {

    //! The Logger class provides public APIs to log various types of
    //! messages. Each Logger class is associated with a log level which
    //! is set within the Logger.initialize() function.
    (:debug)
    class Logger {

        private var mLogLevel;
        private var mLogStream;

        //! Creates a new Logger object.
        //! @param logLevel [Toybox::Lang::String] The log level value to log messages through this class to
        //! @param logStream [Toybox::Lang::Object] An object which defines a println(message) function
        function initialize(logLevel, logStream) {
            mLogLevel = logLevel;
            mLogStream = logStream;
        }

        // The string formats to use when printing log messages
        private static var FORMAT_VARIABLE = "$1$=($2$) $3$";
        private static var FORMAT_LOG_MESSAGE = "(lmf1)[$1$] {$2$} $3$: $4$";
        private static var FORMAT_TIMESTAMP = "$1$-$2$-$3$ $4$:$5$:$6$"; // YYYY-MM-DD HH:MM:SS

        //! Forms a log message based on the given values.
        //! @param tag [Toybox::Lang::String] The tag to apply to the log message
        //! @param message [Toybox::Lang::String] The message to log
        //! @return [Toybox::Lang::String] A log message matching the format specified by FORMAT_TIMESTAMP
        private function formLogMessage(tag, message) {
            // Get a timestamp from the system
            var currentTime = Greg.info(Time.now(), Time.FORMAT_SHORT);
            var timestamp = Lang.format(FORMAT_TIMESTAMP, [
                currentTime.year.format("%04u"),
                currentTime.month.format("%02u"),
                currentTime.day.format("%02u"),
                currentTime.hour.format("%02u"),
                currentTime.min.format("%02u"),
                currentTime.sec.format("%02u")
            ]);

            // Form the log message
            return Lang.format(FORMAT_LOG_MESSAGE, [timestamp, mLogLevel, tag, message]);
        }

        //! Handles the printing of a log message to the log file
        //! @param tag [Toybox::Lang::String] The tag to apply to the log message
        //! @param message [Toybox::Lang::String] The message to log
        private function log(tag, message) {
            // Print the log message
            mLogStream.println(formLogMessage(tag, message));
        }

        //! Returns the type string of the given variable. Note, this function
        //! will currently only return names within the Toybox.Lang module. If the
        //! given variable isn't a type defined there then "Object" will be returned.
        //! @param variable [Toybox::Lang::Object] The variable to get the type of
        //! @return [Toybox::Lang::String] The name of the type of the given variable
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

        //! Log the given message under the given tag
        //! @param tag [Toybox::Lang::String] The tag to apply to the log message
        //! @param message [Toybox::Lang::String] The message to log
        function logMessage(tag, message) {
            log(tag, message);
        }

        //! Log the given Exception under the given tag
        //! @param tag [Toybox::Lang::String] The tag to apply to the log message
        //! @param exception [Toybox::Lang::Exception] The Exception to log
        function logException(tag, exception) {
            log(tag, exception.getErrorMessage());
            //TODO: Iteratre through stacktrace.
        }

        //! Log the given variable's information under the given tag
        //! @param tag [Toybox::Lang::String] The tag to apply to the log message
        //! @param variableName [Toybox::Lang::String] The name of the variable being logged
        //! @param variable [Toybox::Lang::Object] The variable to log
        function logVariable(tag, variableName, variable) {
            var type = getVariableType(variable);
            var value;
            if (variable == null) {
                value = "null";
            } else {
                value = variable.toString();
            }
            log(tag, Lang.format(FORMAT_VARIABLE, [variableName, type, value]));
        }

    }

}
