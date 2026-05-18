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

public class WateringResultController {

    @FXML private Label scoreLabel;
    @FXML private Label moistureLabel;

    private String deviceId;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        loadResult();
    }

    private void loadResult() {
        try {
            FirebaseService.getInstance().watchHistory(deviceId, 1, new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;
                    
                    DataSnapshot lastHistory = snapshot.getChildren().iterator().next();
                    Long scoreDelta = lastHistory.child("score_delta").getValue(Long.class);
                    Long moistureAfter = lastHistory.child("moisture_after").getValue(Long.class);
                    
                    Platform.runLater(() -> {
                        if (scoreLabel != null) {
                            scoreLabel.setText(scoreDelta != null ? (scoreDelta >= 0 ? "+" + scoreDelta : String.valueOf(scoreDelta)) : "-");
                        }
                        if (moistureLabel != null) {
                            moistureLabel.setText(moistureAfter != null ? moistureAfter + "%" : "-%");
                        }
                    });
                }

                @Override
                public void onCancelled(DatabaseError error) {}
            });
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void handleBack(ActionEvent event) {
        System.out.println("Returning to dashboard.");
        Main.closeModal();
    }
}
