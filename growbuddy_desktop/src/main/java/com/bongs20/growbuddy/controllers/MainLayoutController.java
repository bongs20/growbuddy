package com.bongs20.growbuddy.controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.layout.StackPane;

import java.io.IOException;

import com.bongs20.growbuddy.services.FirebaseService;
import com.bongs20.growbuddy.services.NotificationService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import java.awt.TrayIcon.MessageType;

public class MainLayoutController {

    @FXML
    private StackPane contentArea;

    @FXML
    private Button btnHome;

    @FXML
    private Button btnHistory;

    @FXML
    private Button btnMissions;

    @FXML
    private Button btnSettings;

    private String deviceId;
    private ValueEventListener notificationListener;

    public void initData(String deviceId) {
        this.deviceId = deviceId;
        showHome(null);
        setupNotificationListener();
    }

    private void setupNotificationListener() {
        try {
            FirebaseService firebaseService = FirebaseService.getInstance();
            notificationListener = new ValueEventListener() {
                private boolean isFirstLoad = true;
                private Boolean lastOnlineStatus = null;

                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;

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
                    
                    Long moistureLong = snapshot.child("moisture").getValue(Long.class);
                    int moisture = moistureLong != null ? moistureLong.intValue() : 0;

                    if (isFirstLoad) {
                        isFirstLoad = false;
                        lastOnlineStatus = isActuallyOnline;
                        return; // Don't spam notifications on initial load
                    }

                    // Check if went offline
                    if (!isActuallyOnline && (lastOnlineStatus == null || lastOnlineStatus)) {
                        NotificationService.getInstance().showNotification("Peringatan Alat!", "Alat GrowBuddy (" + deviceId + ") terputus dari jaringan.", MessageType.WARNING);
                    }
                    lastOnlineStatus = isActuallyOnline;

                    // Check low moisture
                    if (moisture < 30 && isActuallyOnline) {
                        // In a real app we'd debounce this so it doesn't notify every second
                        // NotificationService.getInstance().showNotification("Tanah Kering", "Kelembapan saat ini " + moisture + "%. Ayo siram tanamanmu!", MessageType.INFO);
                    }
                }

                @Override
                public void onCancelled(DatabaseError error) {}
            };
            firebaseService.watchDevice(deviceId, notificationListener);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void showHome(ActionEvent event) {
        setActiveButton(btnHome);
        loadView("/fxml/HomeDashboard.fxml");
    }

    @FXML
    public void showHistory(ActionEvent event) {
        setActiveButton(btnHistory);
        loadView("/fxml/History.fxml");
    }

    @FXML
    public void showMissions(ActionEvent event) {
        setActiveButton(btnMissions);
        loadView("/fxml/Missions.fxml");
    }

    @FXML
    public void showSettings(ActionEvent event) {
        setActiveButton(btnSettings);
        loadView("/fxml/Settings.fxml");
    }

    private void setActiveButton(Button activeButton) {
        Button[] buttons = {btnHome, btnHistory, btnMissions, btnSettings};
        for (Button btn : buttons) {
            btn.getStyleClass().remove("nav-active");
            if (btn == activeButton) {
                btn.getStyleClass().add("nav-active");
            }
        }
    }

    private void loadView(String fxmlPath) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource(fxmlPath));
            Node view = loader.load();
            
            // Pass deviceId to controller if needed
            Object controller = loader.getController();
            if (controller instanceof HomeDashboardController) {
                ((HomeDashboardController) controller).initData(deviceId);
            } else if (controller instanceof HistoryController) {
                ((HistoryController) controller).initData(deviceId);
            } else if (controller instanceof MissionsController) {
                ((MissionsController) controller).initData(deviceId);
            } else if (controller instanceof SettingsController) {
                ((SettingsController) controller).initData(deviceId);
            } else if (controller instanceof NotificationsController) {
                ((NotificationsController) controller).initData(deviceId);
            }
            
            contentArea.getChildren().setAll(view);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
