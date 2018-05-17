using Toybox.Communications;

// Delegate injects a context argument into web request response callback
class RequestDelegate
{
    hidden var mCallback; // function always takes 3 arguments
    hidden var mContext;  // this is the 3rd argument

    function initialize(callback, context) {
        mCallback = callback;
        mContext = context;
    }

    // Perform the request using the previously configured callback
    function makeWebRequest(url, params, options) {
        Communications.makeWebRequest(url, params, options, self.method(:onWebResponse));
    }

    // Forward the response data and the previously configured context
    function onWebResponse(code, data) {
        mCallback.invoke(code, data, mContext);
    }
}
