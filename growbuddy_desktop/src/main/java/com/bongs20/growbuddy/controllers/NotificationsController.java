package com.bongs20.growbuddy.controllers;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.geometry.Pos;
import javafx.scene.control.Label;
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

public class NotificationsController implements Initializable {

    @FXML
    private VBox notificationsContainer;

    private String deviceId;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        loadNotifications();
    }

    @Override
    public void initialize(URL location, ResourceBundle resources) {
    }

    private void loadNotifications() {
        try {
            FirebaseService.getInstance().watchDevice(deviceId, new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;

                    Boolean isOnlineFlag = snapshot.child("online").getValue(Boolean.class);
                    Long moistureLong = snapshot.child("moisture").getValue(Long.class);
                    int moisture = moistureLong != null ? moistureLong.intValue() : 0;
                    String status = snapshot.child("status").getValue(String.class);
                    
                    Long lastUpdate = snapshot.child("last_update").getValue(Long.class);
                    String tempTime = "--:--";
                    boolean tempOnline = false;
                    if (lastUpdate != null) {
                        long lastUpdateTimeMillis = lastUpdate < 1000000000000L ? lastUpdate * 1000 : lastUpdate;
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM HH:mm");
                        tempTime = sdf.format(new Date(lastUpdateTimeMillis));
                        if (isOnlineFlag != null && isOnlineFlag) {
                            long diffMillis = System.currentTimeMillis() - lastUpdateTimeMillis;
                            tempOnline = diffMillis < 120000; // 2 minutes threshold
                        }
                    }
                    final String time = tempTime;
                    final boolean isActuallyOnline = tempOnline;

                    Platform.runLater(() -> {
                        // Clear the heading and recreate it
                        notificationsContainer.getChildren().clear();
                        Label heading = new Label("Notifikasi");
                        heading.getStyleClass().add("heading");
                        notificationsContainer.getChildren().add(heading);

                        boolean hasNotifs = false;

                        if (!isActuallyOnline) {
                            addNotificationCard("WiFi", "#F4E4DF", "#9B3D2F", "Perangkat sedang offline", "Terakhir aktif pada " + time + ".");
                            hasNotifs = true;
                        }

                        if (moisture < 30) {
                            addNotificationCard("Tanah", "#FEE4BF", "#8A4B00", "Tanah mulai kering", "Kelembapan saat ini " + moisture + "%. Pertimbangkan penyiraman.");
                            hasNotifs = true;
                        } else if ("overwatered".equals(status)) {
                            addNotificationCard("Tanah", "#E3F1FF", "#245B90", "Tanah terlalu basah", "Kelembapan saat ini " + moisture + "%. Tunda penyiraman berikutnya.");
                            hasNotifs = true;
                        }
                        
                        String execStatus = snapshot.child("control").child("execution_status").getValue(String.class);
                        if ("completed".equals(execStatus)) {
                            addNotificationCard("Info", "#EAF7EC", "#376A25", "Penyiraman selesai", "Perangkat berhasil menyelesaikan penyiraman.");
                            hasNotifs = true;
                        } else if ("skipped".equals(execStatus)) {
                            addNotificationCard("Info", "#F4EED8", "#735C00", "Penyiraman dilewati", "Sistem membatalkan penyiraman (kondisi tidak memenuhi).");
                            hasNotifs = true;
                        }

                        if (!hasNotifs) {
                            Label empty = new Label("Belum ada notifikasi penting.");
                            empty.setStyle("-fx-text-fill: #5E6653;");
                            notificationsContainer.getChildren().add(empty);
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

    private void addNotificationCard(String iconStr, String iconBg, String iconColor, String title, String message) {
        HBox card = new HBox(14);
        card.getStyleClass().add("card");
        
        Label icon = new Label(iconStr.substring(0,1));
        icon.setAlignment(Pos.CENTER);
        icon.setPrefSize(46, 46);
        icon.setStyle("-fx-background-color: " + iconBg + "; -fx-text-fill: " + iconColor + "; -fx-background-radius: 14; -fx-font-size: 20px; -fx-font-weight: bold;");
        
        VBox textBox = new VBox(6);
        HBox.setHgrow(textBox, Priority.ALWAYS);
        
        Label titleLabel = new Label(title);
        titleLabel.setStyle("-fx-font-size: 16px; -fx-font-weight: 800; -fx-text-fill: #1E1C0F;");
        
        Label msgLabel = new Label(message);
        msgLabel.setStyle("-fx-text-fill: #5E6653;");
        msgLabel.setWrapText(true);
        
        textBox.getChildren().addAll(titleLabel, msgLabel);
        card.getChildren().addAll(icon, textBox);
        
        notificationsContainer.getChildren().add(card);
    }
}
