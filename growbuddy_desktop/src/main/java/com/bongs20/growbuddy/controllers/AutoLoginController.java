package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import com.bongs20.growbuddy.services.FirebaseService;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.Label;

import java.io.IOException;

public class AutoLoginController {

    @FXML
    private Label statusLabel;

    @FXML
    public void initialize() {
        // Start a background thread to initialize Firebase so UI doesn't freeze
        new Thread(() -> {
            try {
                FirebaseService.getInstance();
                Platform.runLater(() -> {
                    statusLabel.setText("Berhasil terhubung!");
                    
                    // Check Preferences for saved deviceId
                    java.util.prefs.Preferences prefs = java.util.prefs.Preferences.userNodeForPackage(com.bongs20.growbuddy.Main.class);
                    String savedDeviceId = prefs.get("deviceId", null);
                    
                    if (savedDeviceId != null && !savedDeviceId.isEmpty()) {
                        System.out.println("Auto-login as: " + savedDeviceId);
                        Main.navigateToDashboard(savedDeviceId);
                    } else {
                        Main.navigateToDeviceSelection(); 
                    }
                });
            } catch (IOException e) {
                Platform.runLater(() -> {
                    statusLabel.setText("Gagal! Pastikan file serviceAccountKey.json ada di folder root.");
                    statusLabel.setStyle("-fx-text-fill: red;");
                });
            } catch (Exception e) {
                Platform.runLater(() -> {
                    statusLabel.setText("Error: " + e.getMessage());
                    statusLabel.setStyle("-fx-text-fill: red;");
                });
            }
        }).start();
    }
}
