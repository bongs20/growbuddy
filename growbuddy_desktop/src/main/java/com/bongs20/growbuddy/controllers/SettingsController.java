package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import com.bongs20.growbuddy.services.FirebaseService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Label;

import java.io.IOException;

public class SettingsController {

    @FXML private Label wifiNameLabel;
    @FXML private Label espStatusLabel;
    @FXML private Label deviceIdLabel;
    @FXML private Label pumpDurationLabel;

    private String deviceId;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        if (deviceIdLabel != null) {
            deviceIdLabel.setText(deviceId);
        }
        loadData();
    }

    private void loadData() {
        try {
            FirebaseService.getInstance().watchDevice(deviceId, new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;

                    Boolean isOnlineFlag = snapshot.child("online").getValue(Boolean.class);
                    Long lastUpdate = snapshot.child("last_update").getValue(Long.class);
                    Long pumpDur = snapshot.child("config").child("pump_duration").getValue(Long.class);
                    
                    boolean tempOnline = false;
                    if (isOnlineFlag != null && isOnlineFlag) {
                        if (lastUpdate != null) {
                            long lastUpdateTimeMillis = lastUpdate < 1000000000000L ? lastUpdate * 1000 : lastUpdate;
                            long diffMillis = System.currentTimeMillis() - lastUpdateTimeMillis;
                            tempOnline = diffMillis < 120000; // 2 minutes threshold
                        }
                    }
                    final boolean isActuallyOnline = tempOnline;
                    
                    Platform.runLater(() -> {
                        wifiNameLabel.setText(isActuallyOnline ? "Terkoneksi" : "Terputus");
                        espStatusLabel.setText(isActuallyOnline ? "Online" : "Offline");
                        pumpDurationLabel.setText(pumpDur != null ? pumpDur + " detik" : "10 detik");
                    });
                }

                @Override
                public void onCancelled(DatabaseError error) {}
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void handleEditCalibration(ActionEvent event) {
        System.out.println("Navigating to calibration for: " + deviceId);
        Main.navigateToCalibration(deviceId);
    }

    @FXML
    public void handleEditProfile(ActionEvent event) {
        System.out.println("Opening edit profile modal for: " + deviceId);
        Main.showModal("/fxml/EditProfileModal.fxml", deviceId);
    }

    @FXML
    public void handleEditPumpDuration(ActionEvent event) {
        System.out.println("Opening edit pump duration modal for: " + deviceId);
        Main.showModal("/fxml/EditPumpDurationModal.fxml", deviceId);
    }

    @FXML
    public void handleUnlink(ActionEvent event) {
        // Clear device from Preferences and go back to DeviceSelection
        System.out.println("Unlinking device...");
        java.util.prefs.Preferences prefs = java.util.prefs.Preferences.userNodeForPackage(com.bongs20.growbuddy.Main.class);
        prefs.remove("deviceId");
        
        Main.navigateToDeviceSelection();
    }
}
