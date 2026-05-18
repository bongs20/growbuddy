package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;

public class DeviceSelectionController {

    @FXML
    private TextField deviceIdInput;

    @FXML
    private Button btnDemo;

    @FXML
    private Button btnConnect;

    @FXML
    private Button btnAdmin;
    
    @FXML
    private Label errorLabel;

    @FXML
    public void handleDemoDevice(ActionEvent event) {
        deviceIdInput.setText("demo_esp32_001");
        handleConnectDevice(event);
    }

    @FXML
    public void handleConnectDevice(ActionEvent event) {
        String deviceId = deviceIdInput.getText().trim();
        if (deviceId.isEmpty()) {
            showError("Device ID wajib diisi.");
            return;
        }
        if (deviceId.contains(" ")) {
            showError("Device ID tidak boleh mengandung spasi.");
            return;
        }
        
        // Hide error
        errorLabel.setVisible(false);
        
        System.out.println("Validating device ID: " + deviceId);
        
        try {
            com.bongs20.growbuddy.services.FirebaseService.getInstance().getDeviceReference(deviceId).addListenerForSingleValueEvent(new com.google.firebase.database.ValueEventListener() {
                @Override
                public void onDataChange(com.google.firebase.database.DataSnapshot snapshot) {
                    javafx.application.Platform.runLater(() -> {
                        if (snapshot.exists()) {
                            System.out.println("Connecting to device: " + deviceId);
                            java.util.prefs.Preferences prefs = java.util.prefs.Preferences.userNodeForPackage(com.bongs20.growbuddy.Main.class);
                            prefs.put("deviceId", deviceId);
                            Main.navigateToDashboard(deviceId);
                        } else {
                            showError("Device ID tidak ditemukan di database.");
                        }
                    });
                }

                @Override
                public void onCancelled(com.google.firebase.database.DatabaseError error) {
                    javafx.application.Platform.runLater(() -> {
                        showError("Akses ditolak atau gagal: " + error.getMessage());
                    });
                }
            });
        } catch (java.io.IOException e) {
            showError("Gagal inisialisasi database: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @FXML
    public void handleAdminLogin(ActionEvent event) {
        System.out.println("Navigating to Admin Login...");
        Main.navigateToAdminLogin();
    }
    
    private void showError(String message) {
        errorLabel.setText(message);
        errorLabel.setVisible(true);
    }
}
