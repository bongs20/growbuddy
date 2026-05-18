package com.bongs20.growbuddy.controllers;

import javafx.fxml.Initializable;

import java.net.URL;
import java.util.ResourceBundle;

import com.bongs20.growbuddy.services.FirebaseService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;

import java.io.IOException;

public class MissionsController implements Initializable {

    @FXML private Label moistureLabel;
    @FXML private Label levelLabel;
    @FXML private Label xpLabel;
    @FXML private ProgressBar xpProgress;
    @FXML private Label xpDescLabel;

    private String deviceId;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        loadData();
    }

    @Override
    public void initialize(URL location, ResourceBundle resources) {
    }

    private void loadData() {
        try {
            FirebaseService.getInstance().watchDevice(deviceId, new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;

                    Long moistureLong = snapshot.child("moisture").getValue(Long.class);
                    int moisture = moistureLong != null ? moistureLong.intValue() : 0;

                    Long scoreLong = snapshot.child("game").child("score").getValue(Long.class);
                    Long levelLong = snapshot.child("game").child("level").getValue(Long.class);
                    int score = scoreLong != null ? scoreLong.intValue() : 0;
                    int level = levelLong != null ? levelLong.intValue() : 1;

                    Platform.runLater(() -> {
                        moistureLabel.setText("Moisture " + moisture + "%");
                        levelLabel.setText("Level " + level);
                        
                        // Simple progression logic (100 * level required to next level)
                        int nextLevelXP = 100 * level;
                        xpLabel.setText(score + " / " + nextLevelXP + " XP");
                        
                        double progress = (double) score / nextLevelXP;
                        if (progress > 1.0) progress = 1.0;
                        xpProgress.setProgress(progress);
                        
                        int xpNeeded = nextLevelXP - score;
                        if (xpNeeded < 0) xpNeeded = 0;
                        xpDescLabel.setText(xpNeeded + " XP lagi untuk naik level. Total skor saat ini " + score + ".");
                    });
                }

                @Override
                public void onCancelled(DatabaseError error) {}
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
