package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;

public class ConnectDeviceManualController {

    @FXML
    private TextField deviceIdInput;

    @FXML
    private Button btnConnect;

    @FXML
    private Label errorLabel;

    @FXML
    public void handleBack(ActionEvent event) {
        Main.navigateToDeviceSelection();
    }

    @FXML
    public void handleConnect(ActionEvent event) {
        String deviceId = deviceIdInput.getText().trim();
        if (deviceId.isEmpty()) {
            showError("Masukkan Device ID terlebih dahulu");
            return;
        }

        errorLabel.setVisible(false);

        System.out.println("Validating device ID: " + deviceId);
        
        try {
            com.bongs20.growbuddy.services.FirebaseService.getInstance().getDeviceReference(deviceId).addListenerForSingleValueEvent(new com.google.firebase.database.ValueEventListener() {
                @Override
                public void onDataChange(com.google.firebase.database.DataSnapshot snapshot) {
                    javafx.application.Platform.runLater(() -> {
                        if (snapshot.exists()) {
                            System.out.println("Connecting to manual device: " + deviceId);
                            java.util.prefs.Preferences prefs = java.util.prefs.Preferences.userNodeForPackage(com.bongs20.growbuddy.Main.class);
                            prefs.put("deviceId", deviceId);
                            Main.navigateToDashboard(deviceId);
                        } else {
                            showError("Device ID tidak ditemukan di database");
                        }
                    });
                }

                @Override
                public void onCancelled(com.google.firebase.database.DatabaseError error) {
                    javafx.application.Platform.runLater(() -> {
                        showError("Gagal memeriksa database: " + error.getMessage());
                    });
                }
            });
        } catch (java.io.IOException e) {
            showError("Gagal inisialisasi database: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @FXML
    public void handleScanQr(ActionEvent event) {
        showError("Fitur scan QR akan hadir segera");
    }

    private void showError(String message) {
        errorLabel.setText(message);
        errorLabel.setVisible(true);
    }
}
