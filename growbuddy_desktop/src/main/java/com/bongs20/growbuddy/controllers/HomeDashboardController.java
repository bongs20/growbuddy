package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.services.FirebaseService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;

import java.io.IOException;

public class HomeDashboardController {

    @FXML private Label deviceIdLabel;
    @FXML private Label statusLabel;
    @FXML private Label onlineBadge;
    @FXML private ProgressBar moistureProgress;
    @FXML private Label moistureLabel;
    @FXML private Label scoreLabel;
    @FXML private Label levelLabel;
    @FXML private Button btnSiram;

    private String deviceId;
    private FirebaseService firebaseService;
    private int currentMoisture = 0;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        if (deviceIdLabel != null) {
            deviceIdLabel.setText(deviceId);
        }
        setupFirebaseListener();
    }

    @FXML
    public void initialize() {
        try {
            firebaseService = FirebaseService.getInstance();
            if (deviceId != null) {
                deviceIdLabel.setText(deviceId);
            }

            btnSiram.setOnAction(e -> handleSiram());
        } catch (IOException e) {
            statusLabel.setText("Firebase Error");
        }
    }

    private void setupFirebaseListener() {
        firebaseService.watchDevice(deviceId, new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                if (!snapshot.exists()) return;

                // Read values safely
                Long moistureLong = snapshot.child("moisture").getValue(Long.class);
                int moisture = moistureLong != null ? moistureLong.intValue() : 0;
                String status = snapshot.child("status").getValue(String.class);
                Boolean isOnlineFlag = snapshot.child("online").getValue(Boolean.class);
                Long lastUpdate = snapshot.child("last_update").getValue(Long.class);
                
                boolean tempOnline = false;
                if (isOnlineFlag != null && isOnlineFlag) {
                    if (lastUpdate != null) {
                        long lastUpdateTimeMillis = lastUpdate < 1000000000000L ? lastUpdate * 1000 : lastUpdate;
                        long diffMillis = System.currentTimeMillis() - lastUpdateTimeMillis;
                        tempOnline = diffMillis < 120000; // 2 minutes threshold
                    }
                }
                final boolean isActuallyOnline = tempOnline;

                Long score = snapshot.child("game").child("score").getValue(Long.class);
                Long level = snapshot.child("game").child("level").getValue(Long.class);
                Boolean siramReq = snapshot.child("control").child("siram").getValue(Boolean.class);

                // Update UI on JavaFX thread
                Platform.runLater(() -> {
                    currentMoisture = moisture;
                    updateUI(status, isActuallyOnline, score, level, siramReq != null && siramReq);
                });
            }

            @Override
            public void onCancelled(DatabaseError error) {
                Platform.runLater(() -> statusLabel.setText("Database Error"));
            }
        });
    }

    private void updateUI(String status, boolean online, Long score, Long level, boolean siramReq) {
        statusLabel.setText(status != null ? status : "unknown");
        moistureLabel.setText(currentMoisture + "%");
        moistureProgress.setProgress(currentMoisture / 100.0);

        if (online) {
            onlineBadge.setText("Online");
            onlineBadge.getStyleClass().remove("badge-offline");
            if (!onlineBadge.getStyleClass().contains("badge-online")) {
                onlineBadge.getStyleClass().add("badge-online");
            }
            btnSiram.setDisable(siramReq);
            btnSiram.setText(siramReq ? "Memproses..." : "Siram Sekarang");
        } else {
            onlineBadge.setText("Offline");
            onlineBadge.getStyleClass().remove("badge-online");
            if (!onlineBadge.getStyleClass().contains("badge-offline")) {
                onlineBadge.getStyleClass().add("badge-offline");
            }
            btnSiram.setDisable(true);
        }

        scoreLabel.setText(score != null ? String.valueOf(score) : "0");
        levelLabel.setText(level != null ? String.valueOf(level) : "0");
    }

    private void handleSiram() {
        // Instead of triggering directly, open the confirmation modal
        com.bongs20.growbuddy.Main.showModal("/fxml/WateringConfirmation.fxml", deviceId);
    }
}
