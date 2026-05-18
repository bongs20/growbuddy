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

public class EditProfileController {

    @FXML private TextField plantTypeInput;

    private String deviceId;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        loadProfile();
    }

    private void loadProfile() {
        try {
            FirebaseService.getInstance().getDeviceReference(deviceId)
                    .child("calibration")
                    .addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot snapshot) {
                            if (!snapshot.exists()) return;
                            String plantType = snapshot.child("plant_type").getValue(String.class);
                            Platform.runLater(() -> {
                                if (plantTypeInput != null && plantType != null) {
                                    plantTypeInput.setText(plantType);
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
        String plantType = plantTypeInput.getText().trim();
        if (plantType.isEmpty()) {
            plantType = "Umum";
        }

        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("calibration/plant_type", plantType);
            updates.put("calibration/last_updated", System.currentTimeMillis() / 1000);

            FirebaseService.getInstance().getDeviceReference(deviceId).updateChildren(updates, (error, ref) -> {
                Platform.runLater(() -> {
                    if (error == null) {
                        Main.closeModal();
                    } else {
                        System.err.println("Error saving profile: " + error.getMessage());
                    }
                });
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void handleCancel(ActionEvent event) {
        Main.closeModal();
    }
}
