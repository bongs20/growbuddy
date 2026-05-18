package com.bongs20.growbuddy.services;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class DemoSimulatorService {

    private static DemoSimulatorService instance;
    private ScheduledExecutorService scheduler;
    private ValueEventListener controlListener;
    private boolean running = false;
    private String deviceId;

    private DemoSimulatorService() {}

    public static synchronized DemoSimulatorService getInstance() {
        if (instance == null) {
            instance = new DemoSimulatorService();
        }
        return instance;
    }

    public synchronized void start(String deviceId) {
        if (running) {
            if (deviceId.equals(this.deviceId)) {
                return;
            }
            stop();
        }

        this.deviceId = deviceId;
        running = true;

        System.out.println("Starting Demo Simulator for: " + deviceId);

        try {
            FirebaseService fs = FirebaseService.getInstance();
            DatabaseReference devRef = fs.getDeviceReference(deviceId);

            // 1. Initialize standard dev values
            devRef.child("online").setValueAsync(true);
            devRef.child("last_update").setValueAsync(System.currentTimeMillis() / 1000);
            devRef.child("status").setValueAsync("Siap");
            devRef.child("config/pump_duration").setValueAsync(5);

            // Set game values if they do not exist
            devRef.addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.child("game").exists()) {
                        devRef.child("game/level").setValueAsync(1);
                        devRef.child("game/score").setValueAsync(10);
                    }
                    if (!snapshot.child("moisture").exists()) {
                        devRef.child("moisture").setValueAsync(60);
                    }
                }
                @Override
                public void onCancelled(DatabaseError error) {}
            });

            // 2. Start moisture drop and heartbeat updater
            scheduler = Executors.newSingleThreadScheduledExecutor(runnable -> {
                Thread thread = new Thread(runnable, "demo-simulator-thread");
                thread.setDaemon(true);
                return thread;
            });

            scheduler.scheduleAtFixedRate(() -> {
                try {
                    // Update last update to stay online
                    devRef.child("last_update").setValueAsync(System.currentTimeMillis() / 1000);

                    // Decrease moisture
                    devRef.child("moisture").addListenerForSingleValueEvent(new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot snapshot) {
                            if (snapshot.exists()) {
                                Long currentVal = snapshot.getValue(Long.class);
                                int m = currentVal != null ? currentVal.intValue() : 60;
                                if (m > 15) {
                                    int nextMoisture = m - 1;
                                    devRef.child("moisture").setValueAsync(nextMoisture);
                                    
                                    // Update status based on soil moisture
                                    if (nextMoisture < 30) {
                                        devRef.child("status").setValueAsync("Tanah kering! Siram segera.");
                                    } else if (nextMoisture < 50) {
                                        devRef.child("status").setValueAsync("Perlu disiram.");
                                    } else {
                                        devRef.child("status").setValueAsync("Tanaman Sehat");
                                    }
                                }
                            }
                        }
                        @Override
                        public void onCancelled(DatabaseError error) {}
                    });
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }, 5, 5, TimeUnit.SECONDS);

            // 3. Listen to siram commands
            controlListener = new ValueEventListener() {
                private boolean isWatering = false;

                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    if (!snapshot.exists()) return;

                    Boolean siram = snapshot.child("control").child("siram").getValue(Boolean.class);
                    if (siram != null && siram && !isWatering) {
                        isWatering = true;
                        System.out.println("Demo Simulator received siram command!");

                        devRef.child("status").setValueAsync("Memulai Pompa...");
                        devRef.child("control/execution_status").setValueAsync("running");

                        // Simulate 3 seconds pump watering
                        scheduler.schedule(() -> {
                            try {
                                devRef.addListenerForSingleValueEvent(new ValueEventListener() {
                                    @Override
                                    public void onDataChange(DataSnapshot snap) {
                                        Long moistureVal = snap.child("moisture").getValue(Long.class);
                                        int mBefore = moistureVal != null ? moistureVal.intValue() : 40;
                                        int mAfter = Math.min(85, mBefore + 35);

                                        Long levelVal = snap.child("game").child("level").getValue(Long.class);
                                        int currentLvl = levelVal != null ? levelVal.intValue() : 1;

                                        Long scoreVal = snap.child("game").child("score").getValue(Long.class);
                                        int currentScore = scoreVal != null ? scoreVal.intValue() : 10;

                                        // High score delta if soil was dry
                                        int scoreDelta = 25;
                                        if (mBefore < 30) {
                                            scoreDelta = 40;
                                        }

                                        int newScore = currentScore + scoreDelta;
                                        int newLevel = currentLvl;
                                        if (newScore >= 100) {
                                            newLevel += 1;
                                            newScore = newScore % 100;
                                        }

                                        devRef.child("moisture").setValueAsync(mAfter);
                                        devRef.child("game/score").setValueAsync(newScore);
                                        devRef.child("game/level").setValueAsync(newLevel);
                                        devRef.child("status").setValueAsync("Siap");

                                        // History item
                                        String historyId = UUID.randomUUID().toString().substring(0, 8);
                                        Map<String, Object> historyItem = new HashMap<>();
                                        historyItem.put("moisture_before", mBefore);
                                        historyItem.put("moisture_after", mAfter);
                                        historyItem.put("score_delta", scoreDelta);
                                        historyItem.put("timestamp", System.currentTimeMillis() / 1000);
                                        historyItem.put("triggered_by", "demo_user");

                                        devRef.child("history").child(historyId).setValueAsync(historyItem);

                                        devRef.child("control/siram").setValueAsync(false);
                                        devRef.child("control/execution_status").setValueAsync("completed");
                                        isWatering = false;
                                    }

                                    @Override
                                    public void onCancelled(DatabaseError error) {
                                        isWatering = false;
                                    }
                                });
                            } catch (Exception e) {
                                e.printStackTrace();
                                isWatering = false;
                            }
                        }, 3, TimeUnit.SECONDS);
                    }
                }

                @Override
                public void onCancelled(DatabaseError error) {}
            };

            devRef.addValueEventListener(controlListener);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public synchronized void stop() {
        if (!running) return;

        System.out.println("Stopping Demo Simulator");
        running = false;

        if (scheduler != null) {
            scheduler.shutdownNow();
            scheduler = null;
        }

        if (controlListener != null && deviceId != null) {
            try {
                FirebaseService.getInstance().getDeviceReference(deviceId).removeEventListener(controlListener);
            } catch (IOException e) {
                e.printStackTrace();
            }
            controlListener = null;
        }
    }
}
