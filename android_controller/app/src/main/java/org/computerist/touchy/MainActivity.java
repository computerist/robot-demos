package org.computerist.touchy;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.companion.AssociationRequest;
import android.companion.BluetoothDeviceFilter;
import android.companion.CompanionDeviceManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.ParcelUuid;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.widget.Button;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.UUID;
import java.util.regex.Pattern;

class ConnectionInfo {
    static ConnectionInfo connectionInfo = new ConnectionInfo();

    static ConnectionInfo getConnectionInfo() {
        return connectionInfo;
    }

    private boolean initialized = false;
    private PrintWriter mWriter;

    boolean isInitialized() {
        return initialized;
    }

    void initialize(PrintWriter writer) {
        this.mWriter = writer;
        this.initialized = true;
    }

    void sendMessage(String message) throws IOException {
        if(this.isInitialized()) {
            System.out.println(message);
            this.mWriter.println(message);
            this.mWriter.flush();
        } else {
            //throw new IOException("Connection not initialised");
            System.out.println("not initialized");
        }
    }
}

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        View v = findViewById(R.id.imageView);

        v.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                int width = view.getWidth();
                int height = view.getHeight();

                int xCalc = 255;
                int yCalc = 255;

                if(motionEvent.getAction() == MotionEvent.ACTION_UP) {
                    System.out.println("Action *UP*");
                } else {
                    xCalc = (int) ((motionEvent.getX() / (float) width) * (float) 511);
                    yCalc = (int) ((1 - motionEvent.getY() / (float) height) * (float) 511);
                }

                ConnectionInfo conn = ConnectionInfo.getConnectionInfo();
                try {
                    conn.sendMessage(xCalc + "," + yCalc);
                } catch (IOException e) {
                    e.printStackTrace();
                }

                return true;
            }
        });

        Button b = findViewById(R.id.button);
        b.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                findBT();
            }
        });

        findBT();
    }

    void checkPermissions() {
        String[] PERMISSIONS_STORAGE = {
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_LOCATION_EXTRA_COMMANDS,
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_PRIVILEGED
        };
        String[] PERMISSIONS_LOCATION = {
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_LOCATION_EXTRA_COMMANDS,
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_PRIVILEGED
        };

        int permission1 = ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        int permission2 = ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN);
        if (permission1 != PackageManager.PERMISSION_GRANTED) {
            // We don't have permission so prompt the user
            ActivityCompat.requestPermissions(
                    this,
                    PERMISSIONS_STORAGE,
                    1
            );
        } else if (permission2 != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                    this,
                    PERMISSIONS_LOCATION,
                    1
            );
        }
    }

    void findBT() {
        checkPermissions();

        BluetoothManager bluetoothManager = getSystemService(BluetoothManager.class);
        BluetoothAdapter bluetoothAdapter = bluetoothManager.getAdapter();
        if (bluetoothAdapter == null) {
            // Device doesn't support Bluetooth
            return;
        }

        BluetoothDeviceFilter deviceFilter = new BluetoothDeviceFilter.Builder()
        // Match only Bluetooth devices whose name matches the pattern.
        .setNamePattern(Pattern.compile("HC-06|linvor|HC-05"))
        .build();
        AssociationRequest pairingRequest = new AssociationRequest.Builder()
                // Find only devices that match this request filter.
                .addDeviceFilter(deviceFilter)
                // Stop scanning as soon as one device matching the filter is found.
                .setSingleDevice(true)
                .build();

        CompanionDeviceManager deviceManager =
                (CompanionDeviceManager) getSystemService(Context.COMPANION_DEVICE_SERVICE);
        deviceManager.associate(pairingRequest, new CompanionDeviceManager.Callback() {
            // Called when a device is found. Launch the IntentSender so the user can
            // select the device they want to pair with.
            @Override
            public void onDeviceFound(IntentSender chooserLauncher) {
                try {
                    startIntentSenderForResult(
                            chooserLauncher, 0, null, 0, 0, 0
                    );
                    System.out.println("Device found...");
                } catch (IntentSender.SendIntentException e) {
                    throw new RuntimeException(e);
                } finally {
                    System.out.println("registering done");
                }
            }

            @Override
            public void onFailure(CharSequence error) {
                // Handle the failure.
                System.out.println("Device discovery failed");
            }
        }, null);
    }

    @SuppressLint("MissingPermission")
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        if (resultCode != Activity.RESULT_OK) {
            System.out.println("Pairing worked OK");
            return;
        }
        if (requestCode == 0 && data != null) {
            BluetoothDevice deviceToPair =
                    data.getParcelableExtra(CompanionDeviceManager.EXTRA_DEVICE);
            if (deviceToPair != null) {
                //deviceToPair.
                //if(true) {
                // {
                try {
                    if(deviceToPair.createBond()) {

                    } else {
                        System.out.println("there was an immediate problem creating a bond");
                    }

                        UUID uuid = null;
                        ParcelUuid[] UUIDs = deviceToPair.getUuids();
                        for (ParcelUuid puuid : UUIDs) {
                            System.out.println(puuid);
                            uuid = puuid.getUuid();
                        }
                        BluetoothSocket socket = deviceToPair.createRfcommSocketToServiceRecord(uuid);
                        socket.connect();
                        PrintWriter writer = new PrintWriter(new OutputStreamWriter(socket.getOutputStream()));
                        ConnectionInfo conn = ConnectionInfo.getConnectionInfo();
                        conn.initialize(writer);


                } catch (Exception e) {
                    e.printStackTrace();
                }

                // Continue to interact with the paired device.
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }
}