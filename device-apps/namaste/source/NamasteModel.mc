//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Activity;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Attention;
using Toybox.FitContributor;
using Toybox.ActivityRecording;


// This class handles the computation of the Quantitative Enlightenment
// metric.
class NamasteModel
{
    // Timer for handling the accelerometer
    hidden var mTimer;
    // Buffer for accel samples
    hidden var mSamples;
    // Counter to keep track of accel samples
    hidden var mSampleCounter;
    // Instantaneous enlightenment
    hidden var mNamaste;
    // Accumulated enlightenment
    hidden var mTotalNamastes;
    // Time elapsed
    hidden var mSeconds;
    // HR zones
    hidden var mZones;
    // FIT recording session
    hidden var mSession;
    // Environment sensor
    var mEnvironmentSensor;
    // FIT field for instantaneous enlightenment
    hidden var mCurrentNamasteField;
    // FIT field for accumulated enlightenment
    hidden var mTotalNamasteField;


    // Initialize sensor readings
    function initialize() {
        // Enable the WHR or ANT HR sensor
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        // Allocate buffer to keep incoming accel samples
        mSamples = new [4];
        // Keep a running counter of the accel samples we've cached
        mSampleCounter = 0;
        // Current instantaneous Namastes
        mNamaste = 0;
        // Total Namastes
        mTotalNamastes = 0;
        // Time elapsed
        mSeconds = 0;
        // Get the user's HR zones
        mZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);

        // Start the sensor reading
        mEnvironmentSensor = new TempeSensor();

        // Create a new FIT recording session
        mSession = ActivityRecording.createSession({:sport=>ActivityRecording.SPORT_GENERIC, :name=>"Yoga"});
        // Create the new FIT fields to record to.
        mCurrentNamasteField = mSession.createField("Current", 1, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_RECORD});
        mTotalNamasteField = mSession.createField("Total", 2, FitContributor.DATA_TYPE_UINT32, {:mesgType => FitContributor.MESG_TYPE_SESSION});
    }

    // Begin sensor processing
    function start() {
        // Start the environment sensor
        mEnvironmentSensor.open();
        // Allocate the timer
        mTimer = new Timer.Timer();
        // Process the sensors at 4 Hz
        mTimer.start(method(:accelCallback), 250, true);
        // Start recording
        mSession.start();
    }

    // Stop sensor processing
    function stop() {
        // Stop the environment sensor
        mEnvironmentSensor.closeSensor();
        // Stop the timer
        mTimer.stop();
        // Stop the FIT recording
        mSession.stop();
    }

    // Save the current session
    function save() {
        mSession.save();
    }

    // Discard the current session
    function discard() {
        mSession.discard();
    }

    // Return the total QE for the entire workout
    function getTotalNamastes() {
        return mTotalNamastes;
    }


    // Return the instantaneous QEs for the given moment.
    function getCurrentNamastes() {
        return mNamaste;
    }

    // Return the total elapsed recording time
    function getTimeElapsed() {
        return mSeconds;
    }

    // Process the accelerometer.
    function accelCallback() {
        var info = Sensor.getInfo();

        // Capture the accel vector
        if( info has :accel) {
            mSamples[mSampleCounter] = info.accel;
        } else {
            mSamples[mSampleCounter] = [1,1,1];
        }
        // Only run computation ever four samples (1 second)
        if (mSampleCounter < 3) {
            mSampleCounter++;
        } else {
            var a, b, magA;
            var result = true;

            // Calculate the first vector and magnitude
            a = mSamples[0];
            magA = Math.sqrt(a[0]*a[0] + a[1]*a[1] + a[2]*a[2] );

            // Use the dot product to get the angle between the four vectors
            // If the angle is greater than cos(10 degrees), then they have
            // moved in the last second significantly.
            for(var i = 1; i < 4; i++) {
                // Compute the second vector and magnitude
                b = mSamples[i];
                var magB = Math.sqrt( b[0]*b[0] + b[1]*b[1] + b[2]*b[2] );
                // Compute the dot product of a . b
                var dot = ( a[0]*b[0] + a[1]*b[1] + a[2]*b[2] ).toFloat() / (magA * magB);

                // If the angle is more than cos(10), then it is outside range
                if( dot < .987) {
                    result = false;
                }

                // Move the current vector into a
                a = b;
                magA = magB;
            }

            // If they have been still, and their heart rate is in
            // HR zone 2, give them a Namaste
            if( result && info.heartRate != null ) {
                if( info.heartRate > mZones[0]) {
                    mNamaste = 1;
                    mTotalNamastes++;
                }
            } else {
                mNamaste = 0;
            }

            // Update the current namaste field
            mCurrentNamasteField.setData( mNamaste );
            // Update the total namastes field
            mTotalNamasteField.setData( mTotalNamastes / 60 );

            // Reset the sample counter
            mSampleCounter = 0;
            mSeconds++;
        }

    }

}