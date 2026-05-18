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

public class WateringConfirmationController {

    @FXML private Label moistureLabel;
    @FXML private Label durationLabel;

    private String deviceId;
    private int currentMoisture = 0;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        loadData();
    }

    private void loadData() {
        try {
            FirebaseService.getInstance().watchDevice(deviceId, new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;
                    
                    Long moistureLong = snapshot.child("moisture").getValue(Long.class);
                    currentMoisture = moistureLong != null ? moistureLong.intValue() : 0;
                    
                    Long durLong = snapshot.child("config").child("pump_duration").getValue(Long.class);
                    int dur = durLong != null ? durLong.intValue() : 10;
                    
                    Platform.runLater(() -> {
                        if (moistureLabel != null) moistureLabel.setText(currentMoisture + "%");
                        if (durationLabel != null) durationLabel.setText(dur + " dtk");
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
    public void handleConfirm(ActionEvent event) {
        System.out.println("Starting watering...");
        try {
            FirebaseService.getInstance().triggerWaterNow("admin_desktop", deviceId, currentMoisture, (error, ref) -> {
                Platform.runLater(() -> {
                    if (error == null) {
                        Main.showModal("/fxml/WateringProgress.fxml", deviceId);
                    }
                });
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void handleCancel(ActionEvent event) {
        System.out.println("Watering cancelled.");
        Main.closeModal();
    }
}
