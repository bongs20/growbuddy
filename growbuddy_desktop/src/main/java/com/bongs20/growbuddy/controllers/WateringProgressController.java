package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import com.bongs20.growbuddy.services.FirebaseService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class WateringProgressController implements Initializable {

    @FXML
    private ProgressBar progressBar;

    @FXML
    private Label statusLabel;

    private String deviceId;
    private ValueEventListener listener;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        listenToProgress();
    }

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        progressBar.setProgress(-1.0); // Indeterminate initially
    }

    private void listenToProgress() {
        try {
            listener = new ValueEventListener() {
                private boolean initialLoad = true;

                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;

                    Boolean siram = snapshot.child("control").child("siram").getValue(Boolean.class);
                    String execStatus = snapshot.child("control").child("execution_status").getValue(String.class);

                    if (initialLoad) {
                        initialLoad = false;
                        return; // Ignore the first state as it might be transitioning
                    }

                    Platform.runLater(() -> {
                        if (siram != null && !siram) {
                            if ("completed".equals(execStatus) || "skipped".equals(execStatus)) {
                                cleanup();
                                Main.showModal("/fxml/WateringResult.fxml", deviceId);
                            }
                        } else if (siram != null && siram) {
                            statusLabel.setText("Sedang menyiram...");
                        }
                    });
                }

                @Override
                public void onCancelled(DatabaseError error) {}
            };
            
            FirebaseService.getInstance().watchDevice(deviceId, listener);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private void cleanup() {
        if (deviceId != null && listener != null) {
            try {
                FirebaseService.getInstance().unwatchDevice(deviceId, listener);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
