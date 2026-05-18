package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import com.bongs20.growbuddy.services.FirebaseService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.TextField;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class EditPumpDurationController {

    @FXML private TextField durationInput;

    private String deviceId;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        loadPumpDuration();
    }

    private void loadPumpDuration() {
        try {
            FirebaseService.getInstance().getDeviceReference(deviceId)
                    .addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot snapshot) {
                            if (!snapshot.exists()) return;
                            
                            Long pumpDur = snapshot.child("settings").child("pump_duration_seconds").getValue(Long.class);
                            if (pumpDur == null) {
                                pumpDur = snapshot.child("config").child("pump_duration").getValue(Long.class);
                            }
                            if (pumpDur == null) {
                                pumpDur = 5L; // Default
                            }
                            
                            final long duration = pumpDur;
                            Platform.runLater(() -> {
                                if (durationInput != null) {
                                    durationInput.setText(String.valueOf(duration));
                                }
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
    public void handleSave(ActionEvent event) {
        String inputStr = durationInput.getText().trim();
        try {
            int duration = Integer.parseInt(inputStr);
            if (duration < 1 || duration > 60) {
                System.err.println("Duration must be between 1 and 60 seconds");
                return;
            }

            Map<String, Object> updates = new HashMap<>();
            updates.put("config/pump_duration", duration);
            updates.put("settings/pump_duration_seconds", duration);
            updates.put("control/duration_seconds", duration);

            FirebaseService.getInstance().getDeviceReference(deviceId).updateChildren(updates, (error, ref) -> {
                Platform.runLater(() -> {
                    if (error == null) {
                        Main.closeModal();
                    } else {
                        System.err.println("Error saving pump duration: " + error.getMessage());
                    }
                });
            });
        } catch (NumberFormatException e) {
            System.err.println("Invalid number format for duration");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void handleCancel(ActionEvent event) {
        Main.closeModal();
    }
}
