package com.bongs20.growbuddy.services;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.database.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;

public class FirebaseService {

    private static FirebaseService instance;
    private final FirebaseDatabase database;

    private FirebaseService() throws IOException {
        java.io.InputStream serviceAccount = getClass().getResourceAsStream("/serviceAccountKey.json");
        if (serviceAccount == null) {
            throw new IOException("Service account key not found at src/main/resources/serviceAccountKey.json");
        }

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .setDatabaseUrl("https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app")
                .build();

        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseApp.initializeApp(options);
        }

        database = FirebaseDatabase.getInstance();
    }

    public static synchronized FirebaseService getInstance() throws IOException {
        if (instance == null) {
            instance = new FirebaseService();
        }
        return instance;
    }

    public DatabaseReference getDeviceReference(String deviceId) {
        return database.getReference("devices").child(deviceId);
    }

    public void watchDevice(String deviceId, ValueEventListener listener) {
        getDeviceReference(deviceId).addValueEventListener(listener);
    }

    public void unwatchDevice(String deviceId, ValueEventListener listener) {
        getDeviceReference(deviceId).removeEventListener(listener);
    }

    public void watchHistory(String deviceId, int limit, ValueEventListener listener) {
        getDeviceReference(deviceId).child("history").orderByKey().limitToLast(limit).addValueEventListener(listener);
    }

    public void unwatchHistory(String deviceId, ValueEventListener listener) {
        getDeviceReference(deviceId).child("history").removeEventListener(listener);
    }

    public void watchAllDevices(ValueEventListener listener) {
        database.getReference("devices").addValueEventListener(listener);
    }

    public void unwatchAllDevices(ValueEventListener listener) {
        database.getReference("devices").removeEventListener(listener);
    }

    public void triggerWaterNow(String uid, String deviceId, int moistureBefore, DatabaseReference.CompletionListener listener) {
        DatabaseReference deviceRef = getDeviceReference(deviceId);
        Map<String, Object> updates = new HashMap<>();
        updates.put("control/siram", true);
        updates.put("control/triggered_by", uid);
        
        deviceRef.updateChildren(updates, listener);
    }
}
