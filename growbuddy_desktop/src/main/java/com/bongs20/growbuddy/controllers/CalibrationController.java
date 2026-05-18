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
import javafx.scene.control.Slider;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class CalibrationController {

    @FXML
    private Label offsetLabel;

    @FXML
    private Slider offsetSlider;

    private String deviceId;
    private boolean isInitialLoad = true;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        
        // Setup slider live listener
        offsetSlider.valueProperty().addListener((observable, oldValue, newValue) -> {
            int val = (int) Math.round(newValue.doubleValue());
            offsetLabel.setText((val > 0 ? "+" : "") + val + "%");
        });

        loadConfig();
    }

    private void loadConfig() {
        try {
            FirebaseService.getInstance().getDeviceReference(deviceId)
                    .addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot snapshot) {
                            if (!snapshot.exists()) return;
                            
                            Long offsetVal = snapshot.child("calibration").child("offset_percent").getValue(Long.class);
                            if (offsetVal == null) {
                                // Fallback
                                offsetVal = snapshot.child("config").child("moisture_calibration").child("offset").getValue(Long.class);
                            }
                            if (offsetVal == null) {
                                offsetVal = 0L;
                            }
                            
                            final long offset = offsetVal;
                            Platform.runLater(() -> {
                                offsetSlider.setValue(offset);
                                int val = (int) offset;
                                offsetLabel.setText((val > 0 ? "+" : "") + val + "%");
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
    public void handleBack(ActionEvent event) {
        Main.navigateToDashboard(deviceId); 
    }

    @FXML
    public void handleSave(ActionEvent event) {
        int offsetVal = (int) Math.round(offsetSlider.getValue());
        System.out.println("Saving calibration offset: " + offsetVal + "%");
        
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("calibration/offset_percent", offsetVal);
            updates.put("calibration/last_updated", System.currentTimeMillis() / 1000);
            updates.put("config/moisture_calibration/offset", offsetVal);
            
            FirebaseService.getInstance().getDeviceReference(deviceId).updateChildren(updates, (error, ref) -> {
                Platform.runLater(() -> {
                    if (error == null) {
                        handleBack(event);
                    } else {
                        System.err.println("Error saving calibration: " + error.getMessage());
                    }
                });
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
