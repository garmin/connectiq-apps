//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.System as Sys;

// Base class for the TransactionDelegate
class TransactionDelegate
{

    // Function to put error handling
    function handleError(error) {
    }

    // Function to put response handling
    function handleResponse(data) {
    }
}

// Base class for transactions to an OAUTH API
class Transaction
{
    hidden var _action;
    hidden var _parameters;
    hidden var _delegate;

    // Constructor
    // @param delegate TransactionDelegate
    hidden function initialize(delegate) {
        _delegate = delegate;
    }

    // Executes the transaction
    function go() {
        var accessToken = App.getApp().getProperty("access_token");
        var url = $.ApiUrl + _action;

        Comm.makeWebRequest(
            url,
            _parameters,
            {
                :method=>Comm.HTTP_REQUEST_METHOD_GET,
                :headers=>{ "Authorization"=>"Bearer " + accessToken }
            },
            method(:onResponse)
        );
    }

    // Handles response from server
    function onResponse(responseCode, data) {
        if(responseCode == 200) {
            _delegate.handleResponse(data);
        } else {
            if(data.hasKey("errors")) {
                var errors = data["errors"];
                for(var i = 0; i < errors.size(); i++) {
                    var error = errors[i];
                    if(error["code"].equals("invalid_client")) {
                        onRenew();
                    } else {
                        _delegate.handleError(error);
                    }
                }
            } else {
                _delegate.handleError(data);
            }
        }
    }

    // Handle renewal of the token
    hidden function onRenew() {
        var refreshToken = App.getApp().getProperty("refresh_token");
        var url = $.ApiUrl + "/token";
        Comm.makeWebRequest(
            url,
            {
                "client_id"=>$.ClientId,
                "grant_type"=>"refresh_token",
                "redirect_uri"=>$.RedirectUri,
                "refresh_token"=>refreshToken
            },
            {
                :method => Comm.HTTP_REQUEST_METHOD_POST
            },
            method(:handleRefresh)
        );
    }

    // Updates the access token
    function handleRefresh(responseCode, data) {
        if(responseCode == 200) {
            App.getApp().setProperty("refresh_token", data["refresh_token"]);
            App.getApp().setProperty("access_token", data["access_token"]);
        } else {
            Sys.println("Received code " + responseCode);
        }
        // Kick off the transaction again
        go();
    }

}