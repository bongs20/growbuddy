package com.bongs20.growbuddy.controllers;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.geometry.Insets;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

import java.net.URL;
import java.util.ResourceBundle;

import com.bongs20.growbuddy.services.FirebaseService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import javafx.application.Platform;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class HistoryController implements Initializable {

    @FXML
    private VBox historyContainer;

    private String deviceId;
    private ValueEventListener historyListener;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        loadHistory();
    }

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        // Init happens before initData, so don't load history yet
    }

    private void loadHistory() {
        try {
            FirebaseService.getInstance().watchHistory(deviceId, 8, new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    List<DataSnapshot> historyList = new ArrayList<>();
                    for (DataSnapshot child : snapshot.getChildren()) {
                        historyList.add(child);
                    }
                    Collections.reverse(historyList); // Newest first

                    Platform.runLater(() -> {
                        historyContainer.getChildren().clear();
                        if (historyList.isEmpty()) {
                            Label emptyLabel = new Label("Belum ada riwayat penyiraman.");
                            emptyLabel.setStyle("-fx-text-fill: #5E6653;");
                            historyContainer.getChildren().add(emptyLabel);
                            return;
                        }

                        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
                        for (DataSnapshot item : historyList) {
                            Long timestamp = item.child("timestamp").getValue(Long.class);
                            String time = timestamp != null ? sdf.format(new Date(timestamp < 1000000000000L ? timestamp * 1000 : timestamp)) : "--:--";
                            
                            Long before = item.child("moisture_before").getValue(Long.class);
                            Long after = item.child("moisture_after").getValue(Long.class);
                            int beforePct = before != null ? before.intValue() : 0;
                            int afterPct = after != null ? after.intValue() : 0;
                            
                            Long delta = item.child("score_delta").getValue(Long.class);
                            int scoreDelta = delta != null ? delta.intValue() : 0;
                            
                            String reason = item.child("score_reason").getValue(String.class);
                            if (reason == null) reason = "Penyiraman berhasil.";
                            
                            String status = scoreDelta >= 0 ? "Tepat" : "Berlebih";
                            addHistoryCard("Penyiraman", time, status, beforePct, afterPct, scoreDelta, reason, scoreDelta >= 0);
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

    private void addHistoryCard(String title, String time, String status, int beforePct, int afterPct, int scoreDelta, String reason, boolean positive) {
        VBox card = new VBox(14);
        card.getStyleClass().add("card");
        card.setStyle("-fx-effect: dropshadow(gaussian, " + (positive ? "rgba(55,106,37,0.08)" : "rgba(155,61,47,0.08)") + ", 18, 0, 0, 6);");

        // Header Row
        HBox headerRow = new HBox(12);
        
        Label iconLabel = new Label("✿");
        iconLabel.setStyle("-fx-font-size: 24px; -fx-text-fill: " + (positive ? "#376A25" : "#9B3D2F") + "; -fx-background-color: " + (positive ? "#B1EFD8" : "#F4E4DF") + "; -fx-background-radius: 14; -fx-padding: 8 16;");
        
        VBox titleBox = new VBox(4);
        HBox.setHgrow(titleBox, Priority.ALWAYS);
        Label titleLabel = new Label(title);
        titleLabel.setStyle("-fx-font-size: 16px; -fx-font-weight: 800;");
        Label subtitleLabel = new Label(time + " • " + status);
        subtitleLabel.setStyle("-fx-font-size: 12px; -fx-font-weight: 700; -fx-text-fill: " + (positive ? "#376A25" : "#9B3D2F") + ";");
        titleBox.getChildren().addAll(titleLabel, subtitleLabel);
        
        Label scoreLabel = new Label((positive ? "+" : "") + scoreDelta);
        scoreLabel.setStyle("-fx-background-color: " + (positive ? "#FFE088" : "#F4E4DF") + "; -fx-background-radius: 10; -fx-padding: 6 10; -fx-font-weight: 800;");
        
        headerRow.getChildren().addAll(iconLabel, titleBox, scoreLabel);
        
        // Moisture Boxes
        HBox moistureRow = new HBox(10);
        moistureRow.getChildren().addAll(
            createMoistureBox("Sebelum", beforePct + "%", "#F4EED8", "#1E1C0F"),
            createMoistureBox("Sesudah", afterPct + "%", positive ? "#B1EFD8" : "#F4E4DF", positive ? "#376A25" : "#9B3D2F")
        );
        
        // Progress
        ProgressBar progress = new ProgressBar(afterPct / 100.0);
        progress.setMaxWidth(Double.MAX_VALUE);
        progress.setStyle("-fx-accent: " + (positive ? "#376A25" : "#9B3D2F") + "; -fx-control-inner-background: #F4EED8;");
        
        // Reason
        Label reasonLabel = new Label(reason);
        reasonLabel.setStyle("-fx-text-fill: #5E6653;");
        reasonLabel.setWrapText(true);
        
        card.getChildren().addAll(headerRow, moistureRow, progress, reasonLabel);
        historyContainer.getChildren().add(card);
    }
    
    private VBox createMoistureBox(String label, String value, String bgColor, String textColor) {
        VBox box = new VBox(6);
        HBox.setHgrow(box, Priority.ALWAYS);
        box.setStyle("-fx-background-color: " + bgColor + "; -fx-background-radius: 14; -fx-padding: 10;");
        Label l = new Label(label);
        l.setStyle("-fx-font-size: 10px; -fx-font-weight: 800; -fx-text-fill: #72796C;");
        Label v = new Label(value);
        v.setStyle("-fx-font-size: 20px; -fx-font-weight: 800; -fx-text-fill: " + textColor + ";");
        box.getChildren().addAll(l, v);
        return box;
    }
}
