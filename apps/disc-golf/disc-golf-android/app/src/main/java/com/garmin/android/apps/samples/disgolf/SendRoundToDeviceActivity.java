/**
 * Copyright 2015 by Garmin Ltd. or its subsidiaries.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.garmin.android.apps.samples.disgolf;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.garmin.android.apps.samples.disgolf.connectivity.WatchConnectionInfo;
import com.garmin.android.apps.samples.disgolf.course.Course;
import com.garmin.android.apps.samples.disgolf.course.Scorecard;
import com.garmin.android.connectiq.ConnectIQ;
import com.garmin.android.connectiq.ConnectIQ.ConnectIQListener;
import com.garmin.android.connectiq.ConnectIQ.IQApplicationEventListener;
import com.garmin.android.connectiq.ConnectIQ.IQApplicationInfoListener;
import com.garmin.android.connectiq.ConnectIQ.IQConnectType;
import com.garmin.android.connectiq.ConnectIQ.IQDeviceEventListener;
import com.garmin.android.connectiq.ConnectIQ.IQMessageStatus;
import com.garmin.android.connectiq.ConnectIQ.IQSdkErrorStatus;
import com.garmin.android.connectiq.ConnectIQ.IQSendMessageListener;
import com.garmin.android.connectiq.IQApp;
import com.garmin.android.connectiq.IQDevice;
import com.garmin.android.connectiq.IQDevice.IQDeviceStatus;
import com.garmin.android.connectiq.exception.InvalidStateException;
import com.garmin.android.connectiq.exception.ServiceUnavailableException;

public class SendRoundToDeviceActivity extends Activity implements ConnectIQListener, IQApplicationInfoListener, IQDeviceEventListener, IQApplicationEventListener, OnItemSelectedListener {

	// ------------------------------------------------------------------------
    // TYPES
    // ------------------------------------------------------------------------

	// ------------------------------------------------------------------------
    // STATIC FIELDS
    // ------------------------------------------------------------------------

	private static final String TAG = SendRoundToDeviceActivity.class.getSimpleName();

	// ------------------------------------------------------------------------
    // STATIC INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC METHODS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // FIELDS
    // ------------------------------------------------------------------------

	private Spinner mDeviceSpinner;
	private TextView mStatusText;
	private Button mSendCourse;

	private Course mCourse;

	// Connect IQ variables
	private boolean mSdkReady;
	private ConnectIQ mConnectIQ;
    private List<IQDevice> mDevices;
    private IQDevice mDevice;
    private IQApp mMyApp;

    // ------------------------------------------------------------------------
    // INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // CONSTRUCTORS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // LIFECYCLE METHODS
    // ------------------------------------------------------------------------

    @Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_send_round_to_device);

		mDeviceSpinner = (Spinner) findViewById(R.id.devices_spinner);
		mStatusText = (TextView) findViewById(R.id.status);
		mStatusText.setText("<select a device>");

		// Setup Connect IQ
		mMyApp = new IQApp(WatchConnectionInfo.APP_ID);
		mConnectIQ = ConnectIQ.getInstance(this, IQConnectType.WIRELESS);
        mConnectIQ.initialize(this, true, this);

        try {
			Bundle bundle = getIntent().getExtras();
			if (bundle != null) {
				mCourse = bundle.getParcelable("course");
			}
		} catch (Exception ex) {
			Log.e(TAG, "Error deparceling course", ex);
		}

        mSendCourse = (Button) findViewById(R.id.start_round_button);
        mSendCourse.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				sendCourseToWatch();
			}
		});
	}

    @Override
    public void onDestroy() {
        super.onDestroy();

        // It is a good idea to unregister everything and shut things down to
        // release resources and prevent unwanted callbacks.
        try {
            mConnectIQ.unregisterAllForEvents();
            mConnectIQ.shutdown(this);
        } catch (InvalidStateException e) {
            // This is usually because the SDK was already shut down
            // so no worries.
        }
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

    private void populateDeviceList() {
    	try {
            mDevices = mConnectIQ.getKnownDevices();

            if (mDevices != null && !mDevices.isEmpty()) {
            	mDevice = mDevices.get(0);
            	registerWithDevice();

            	List<String> deviceNames = new ArrayList<String>();
            	for (IQDevice device : mDevices) {
            		deviceNames.add(device.getFriendlyName());
            	}
            	ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, deviceNames);
            	adapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
                mDeviceSpinner.setAdapter(adapter);
                mDeviceSpinner.setOnItemSelectedListener(this);
            }

        } catch (InvalidStateException e) {
            // This generally means you forgot to call initialize(), but since
            // we are in the callback for initialize(), this should never happen
        } catch (ServiceUnavailableException e) {
            // This will happen if for some reason your app was not able to connect
            // to the ConnectIQ service running within Garmin Connect Mobile.  This
            // could be because Garmin Connect Mobile is not installed or needs to
            // be upgraded.
        	mStatusText.setText(R.string.service_unavailable);
        }
    }

    private void registerWithDevice() {
    	if (mDevice != null && mSdkReady) {
	    	// Register for device status updates
	    	try {
	            mConnectIQ.registerForDeviceEvents(mDevice, this);
	        } catch (InvalidStateException e) {
	            Log.wtf(TAG, "InvalidStateException:  We should not be here!");
	        }

	    	// Register for application status updates
	    	try {
	            mConnectIQ.getApplicationInfo(WatchConnectionInfo.APP_ID, mDevice, this);
	        } catch (InvalidStateException e1) {
	        	Log.d(TAG, "e1: " + e1.getMessage());
	        } catch (ServiceUnavailableException e1) {
	        	Log.d(TAG, "e2: " + e1.getMessage());
	        }

	    	// Register to receive messages from the device
	    	try {
	            mConnectIQ.registerForAppEvents(mDevice, mMyApp, this);
	        } catch (InvalidStateException e) {
	            Toast.makeText(this, "ConnectIQ is not in a valid state", Toast.LENGTH_LONG).show();
	        }
    	}
    }

    private void unregisterWithDevice() {
    	if (mDevice != null && mSdkReady) {
    		// It is a good idea to unregister everything and shut things down to
            // release resources and prevent unwanted callbacks.
            try {
                mConnectIQ.unregisterForDeviceEvents(mDevice);

                if (mMyApp != null) {
                    mConnectIQ.unregisterForApplicationEvents(mDevice, mMyApp);
                }
            } catch (InvalidStateException e) {
            }
    	}
    }

    private void sendCourseToWatch() {
    	try {
			HashMap<Object, Object> message = new HashMap<Object, Object>();
			message.put(AppConstants.KEY_MESSAGE_TYPE, WatchConnectionInfo.MessageType.COURSE.ordinal());
			message.put(AppConstants.KEY_MESSAGE_PAYLOAD, mCourse.toMonkeyObject());
			try {
	            mConnectIQ.sendMessage(mDevice, mMyApp, message, new IQSendMessageListener() {

	                @Override
	                public void onMessageStatus(IQDevice device, IQApp app, IQMessageStatus status) {
	                	Log.d(TAG, "message status: " + status.name());
	                    Toast.makeText(SendRoundToDeviceActivity.this, status.name(), Toast.LENGTH_LONG).show();
	                }

	            });
	            Log.d(TAG, "course sent: " + mCourse.getCourseName());
	        } catch (InvalidStateException e) {
	        	Log.e(TAG, "ConnectIQ is not in a valid state");
	            Toast.makeText(getApplicationContext(), "ConnectIQ is not in a valid state", Toast.LENGTH_LONG).show();
	        } catch (ServiceUnavailableException e) {
	        	Log.e(TAG, "ConnectIQ service is unavailable.   Is Garmin Connect Mobile installed and running?");
	            Toast.makeText(getApplicationContext(), "ConnectIQ service is unavailable.   Is Garmin Connect Mobile installed and running?", Toast.LENGTH_LONG).show();
	        }
		} catch (Exception ex) {
			Toast.makeText(getApplicationContext(), "this isn't good", Toast.LENGTH_SHORT).show();
		}
    }

    // ------------------------------------------------------------------------
    // IQApplicationInfoListener METHODS
    // ------------------------------------------------------------------------

	@Override
	public void onApplicationInfoReceived(IQApp app) {
		Log.d(TAG, "application info received");
	}

	@Override
	public void onApplicationNotInstalled(String arg0) {
		// The disc golf app is not installed on the device so we have
        // to let the user know to install it.
        AlertDialog.Builder dialog = new AlertDialog.Builder(SendRoundToDeviceActivity.this);
        dialog.setTitle(R.string.missing_app_title);
        dialog.setMessage(R.string.missing_app_message);
        dialog.setPositiveButton(android.R.string.ok, null);
        dialog.create().show();
	}

	// ------------------------------------------------------------------------
	// IQDeviceEventListener METHODS
	// ------------------------------------------------------------------------

	@Override
	public void onDeviceStatusChanged(IQDevice device, IQDeviceStatus status) {
		// TODO: make sure the device passed matches the one that's selected
		mStatusText.setText(status.name());
	}

	// ------------------------------------------------------------------------
	// IQApplicationEventListener
	// ------------------------------------------------------------------------

	@Override
	public void onMessageReceived(IQDevice device, IQApp app, List<Object> message, IQMessageStatus status) {
		// We know from our Comm sample widget that it will only ever send us strings, but in case
        // we get something else, we are simply going to do a toString() on each object in the
        // message list.
        StringBuilder builder = new StringBuilder();

        if (message.size() > 0) {
            for (Object o : message) {
            	if (o == null) {
            		builder.append("<null> received");
            	} else if (o instanceof HashMap) {
            		try {
            			@SuppressWarnings("rawtypes")
						Object scorecardDto = ((HashMap) o).get(AppConstants.KEY_MESSAGE_PAYLOAD);
            			@SuppressWarnings("rawtypes")
						Scorecard scorecard = new Scorecard((HashMap) scorecardDto);
            			Intent scorecardIntent = new Intent(this, ScorecardActivity.class);
            			scorecardIntent.putExtra("scorecard", scorecard);
            			startActivity(scorecardIntent);
            			builder = null;
            		} catch (Exception ex) {
            			builder.append("MonkeyHash received:\n\n");
                		builder.append(o.toString());
            		}

            	} else {
            		builder.append(o.toString());
                	builder.append("\r\n");
            	}
            }
        } else {
            builder.append("Received an empty message from the application");
        }

        if (builder != null) {
        	Toast.makeText(getApplicationContext(), builder.toString(), Toast.LENGTH_SHORT).show();
        }
	}

	// ------------------------------------------------------------------------
	// OnItemSelectedListener METHODS
	// ------------------------------------------------------------------------

	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		unregisterWithDevice();
		mDevice = mDevices.get(position);
		registerWithDevice();
		//Toast.makeText(this, "device selected: " + mDevice.getFriendlyName(), Toast.LENGTH_SHORT).show();
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {
		// don't care
	}

	// ------------------------------------------------------------------------
	// ConnectIQListener METHODS
	// ------------------------------------------------------------------------

	@Override
    public void onInitializeError(IQSdkErrorStatus errStatus) {
        Log.d(TAG, "sdk initialization error");
        mSdkReady = false;
    }

    @Override
    public void onSdkReady() {
        Log.d(TAG, "sdk is ready");
        mSdkReady = true;
        populateDeviceList();
    }

    @Override
    public void onSdkShutDown() {
        Log.d(TAG, "sdk shut down");
        mSdkReady = false;
    }

}
