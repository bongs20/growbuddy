package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.cell.PropertyValueFactory;

import com.bongs20.growbuddy.services.FirebaseService;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.net.URL;
import java.util.ResourceBundle;

public class AdminDashboardController implements Initializable {

    @FXML
    private TableView<DeviceData> deviceTable;
    @FXML
    private TableColumn<DeviceData, String> colDeviceId;
    @FXML
    private TableColumn<DeviceData, String> colStatus;
    @FXML
    private TableColumn<DeviceData, String> colConnection;
    @FXML
    private TableColumn<DeviceData, String> colMoisture;
    @FXML
    private TableColumn<DeviceData, String> colLastUpdate;

    private ObservableList<DeviceData> deviceList = FXCollections.observableArrayList();

    private ValueEventListener devicesListener;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        colDeviceId.setCellValueFactory(cellData -> new javafx.beans.property.SimpleStringProperty(cellData.getValue().getDeviceId()));
        colStatus.setCellValueFactory(cellData -> new javafx.beans.property.SimpleStringProperty(cellData.getValue().getStatus()));
        colConnection.setCellValueFactory(cellData -> new javafx.beans.property.SimpleStringProperty(cellData.getValue().getConnection()));
        colMoisture.setCellValueFactory(cellData -> new javafx.beans.property.SimpleStringProperty(cellData.getValue().getMoisture()));
        colLastUpdate.setCellValueFactory(cellData -> new javafx.beans.property.SimpleStringProperty(cellData.getValue().getLastUpdate()));

        deviceTable.setItems(deviceList);
        
        loadDevices();
    }

    private void loadDevices() {
        try {
            devicesListener = new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;

                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM HH:mm");
                    java.util.List<DeviceData> updatedList = new java.util.ArrayList<>();

                    for (DataSnapshot child : snapshot.getChildren()) {
                        String id = child.getKey();
                        String status = child.child("status").getValue(String.class);
                        Boolean online = child.child("online").getValue(Boolean.class);
                        
                        Long moistureLong = child.child("moisture").getValue(Long.class);
                        int moisture = moistureLong != null ? moistureLong.intValue() : 0;
                        
                        Long lastUpdate = child.child("last_update").getValue(Long.class);
                        String time = "-";
                        if (lastUpdate != null) {
                            time = sdf.format(new java.util.Date(lastUpdate < 1000000000000L ? lastUpdate * 1000 : lastUpdate));
                        }
                        
                        String connection = "OFFLINE";
                        if (online != null && online && lastUpdate != null) {
                            long lastUpdateTimeMillis = lastUpdate < 1000000000000L ? lastUpdate * 1000 : lastUpdate;
                            long diffMillis = System.currentTimeMillis() - lastUpdateTimeMillis;
                            if (diffMillis < 120000) { // 2 minutes threshold
                                connection = "ONLINE";
                            }
                        }
                        if (status == null) status = "unknown";
                        
                        updatedList.add(new DeviceData(id, status, connection, moisture + "%", time));
                    }

                    javafx.application.Platform.runLater(() -> {
                        System.out.println("Admin Dashboard updated with " + updatedList.size() + " devices.");
                        deviceList.setAll(updatedList);
                    });
                }

                @Override
                public void onCancelled(DatabaseError error) {
                    System.err.println("Firebase Error: " + error.getMessage() + "\nDetails: " + error.getDetails());
                }
            };
            
            FirebaseService.getInstance().watchAllDevices(devicesListener);
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void handleLogout(ActionEvent event) {
        System.out.println("Admin logged out.");
        Main.navigateToDeviceSelection();
    }

    @FXML
    public void handleAddDevice(ActionEvent event) {
        javafx.scene.control.TextInputDialog dialog = new javafx.scene.control.TextInputDialog("device_");
        dialog.setTitle("Tambah Perangkat");
        dialog.setHeaderText("Masukkan ID perangkat baru:");
        dialog.setContentText("Device ID:");

        java.util.Optional<String> result = dialog.showAndWait();
        result.ifPresent(deviceId -> {
            if (!deviceId.trim().isEmpty()) {
                try {
                    java.util.Map<String, Object> initialData = new java.util.HashMap<>();
                    initialData.put("status", "normal");
                    initialData.put("online", false);
                    initialData.put("moisture", 0);
                    initialData.put("config/pump_duration", 10);
                    initialData.put("config/moisture_calibration/min", 1200);
                    initialData.put("config/moisture_calibration/max", 3200);
                    initialData.put("game/score", 0);
                    initialData.put("game/level", 1);
                    
                    FirebaseService.getInstance().getDeviceReference(deviceId.trim()).updateChildren(initialData, (error, ref) -> {
                        if (error != null) {
                            System.err.println("Gagal menambahkan perangkat: " + error.getMessage());
                        }
                    });
                } catch (java.io.IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    public static class DeviceData {
        private String deviceId;
        private String status;
        private String connection;
        private String moisture;
        private String lastUpdate;

        public DeviceData(String deviceId, String status, String connection, String moisture, String lastUpdate) {
            this.deviceId = deviceId;
            this.status = status;
            this.connection = connection;
            this.moisture = moisture;
            this.lastUpdate = lastUpdate;
        }

        public String getDeviceId() { return deviceId; }
        public String getStatus() { return status; }
        public String getConnection() { return connection; }
        public String getMoisture() { return moisture; }
        public String getLastUpdate() { return lastUpdate; }
    }
}
