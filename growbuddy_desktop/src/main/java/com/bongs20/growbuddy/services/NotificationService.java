package com.bongs20.growbuddy.services;

import java.awt.AWTException;
import java.awt.Image;
import java.awt.SystemTray;
import java.awt.Toolkit;
import java.awt.TrayIcon;
import java.awt.TrayIcon.MessageType;

public class NotificationService {

    private static NotificationService instance;
    private TrayIcon trayIcon;

    private NotificationService() {
        if (SystemTray.isSupported()) {
            try {
                SystemTray tray = SystemTray.getSystemTray();
                // We create a simple 16x16 transparent image for the tray if no icon is provided
                Image image = Toolkit.getDefaultToolkit().createImage(new byte[0]); 
                trayIcon = new TrayIcon(image, "GrowBuddy");
                trayIcon.setImageAutoSize(true);
                tray.add(trayIcon);
            } catch (AWTException e) {
                e.printStackTrace();
            }
        }
    }

    public static synchronized NotificationService getInstance() {
        if (instance == null) {
            instance = new NotificationService();
        }
        return instance;
    }

    public void showNotification(String title, String message, MessageType type) {
        if (trayIcon != null) {
            trayIcon.displayMessage(title, message, type);
        } else {
            System.out.println("NOTIFICATION [" + type + "]: " + title + " - " + message);
        }
    }
}
