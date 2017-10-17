using Toybox.Test as Test;
using Toybox.Lang as Lang;
using LogMonkey as Log;

module LogMonkey {

    // Wrap the unit tests in a module annotated with :test so it will get compiled
    // out for non unit test builds.
    (:test)
    module Test {

        //! This class mocks the Toybox.System.println() interface but instead
        //! of printing a value saves it to a string value which can be retrieved
        //! and examed to verify log results are correct.
        class MockSys {

            private var mStreamContents;

            //! A mock of Toybox.System.println() function
            //! @param [Toybox::Lang::Object] message The message to print/log
            public function println(message) {
                if (mStreamContents == null) {
                    mStreamContents = message + "\n";
                } else {
                    mStreamContents = mStreamContents + message + "\n";
                }
            }

            //! Gets the contents of the fake print stream.
            //! @return [Toybox::Lang::String] The contents that have been "printed" so far
            public function getStreamContents() {
                return mStreamContents;
            }

        }

        // This class is used within the unit tests module to create an Exception
        // object with a custom message.
        class TestException extends Lang.Exception {
            function initialize() {
                Exception.initialize();
                mMessage = "This is a test Exception";
            }
        }

        //! Tests determing the type of a variable
        (:test)
        function testDetermingVariableType(logger) {
            var mockSys;
            var log;
            var logOutput;
            var level = "D";
            var tag = "TAG";
            var varName = "varToTest";
            var varToTest;

            // Test null
            varToTest = null;
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(null)") != null);

            // Test Lang.Array
            varToTest = [1, 2, 3];
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Array)") != null);

            // Test Lang.Boolean
            varToTest = true;
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Boolean)") != null);

            // Test Lang.Char
            varToTest = 'c';
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Char)") != null);

            // Test Lang.Dictionary
            varToTest = { };
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Dictionary)") != null);

            // Test Lang.Double
            varToTest = 3.1415d;
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Double)") != null);

            // Test Lang.Exception
            varToTest = new Lang.Exception();
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Exception)") != null);

            // Test Lang.Float
            varToTest = 3.1415;
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Float)") != null);

            // Test Lang.Long
            varToTest = 1337l;
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Long)") != null);

            // Test Lang.Method
            varToTest = new Lang.Method(Toybox.System, :println);
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Method)") != null);

            // Test Lang.Number
            varToTest = 1337;
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Number)") != null);

            // Test Lang.String
            varToTest = "I am a string of characters";
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(String)") != null);

            // Test Lang.Symbol
            varToTest = :thisIsASymbol;
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Symbol)") != null);

            // Test Lang.WeakReference
            var testObject = new Lang.Object();
            varToTest = testObject.weak();
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(WeakReference)") != null);

            // Test Lang.Object
            varToTest = new Lang.Object();
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Object)") != null);

            // Test an object outside of Toybox.Lang
            varToTest = Toybox.System.getClockTime();
            mockSys = new MockSys();
            log = new $.LogMonkey.Logger(level, mockSys);
            log.logVariable(tag, varName, varToTest);
            logOutput = mockSys.getStreamContents();
            logger.debug("log output: " + logOutput);
            Test.assert(logOutput.find("(Object)") != null);

            // If no asserts are hit then the test passed.
            return true;
        }

        //! Tests the general log output from the LogMonkey.Logger class.
        (:test)
        function testLogOutput(logger) {
            // Setup some local values to log
            var aMessage = "Captain's log, Stardate 31415.9 We have discovered a delicious pie.";
            var anException = new TestException();
            var aString = "this is a string";

            // Create some log variables to log the above values
            logger.debug("Initializing log variables...");
            var logLevel = "D";
            var mockSys = new MockSys();
            var log = new $.LogMonkey.Logger(logLevel, mockSys);

            // Make some test log calls
            logger.debug("Making test log calls...");
            log.logMessage("log verification", aMessage);
            log.logException("log verification", anException);
            log.logVariable("log verification", "aString", aString);

            // Verify the log output
            var logContents = mockSys.getStreamContents();
            logger.debug("Log contents:\n" + logContents);
            logger.debug("Verifying log output...");
            logger.debug("    ...logMessage()...");
            Test.assert(logContents.find("(lmf1)[") != null);
            Test.assert(logContents.find("] {D} log verification: Captain's log, Stardate 31415.9 We have discovered a delicious pie.") != null);
            logger.debug("    ...logException()...");
            Test.assert(logContents.find("(lmf1)[") != null);
            Test.assert(logContents.find("] {D} log verification: This is a test Exception") != null);
            logger.debug("    ...logVariable()...");
            Test.assert(logContents.find("(lmf1)[") != null);
            Test.assert(logContents.find("] {D} log verification: aString=(String) this is a string") != null);

            // If no asserts are hit then the test passed.
            return true;
        }

    }

}
