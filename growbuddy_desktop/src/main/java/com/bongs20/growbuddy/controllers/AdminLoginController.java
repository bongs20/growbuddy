package com.bongs20.growbuddy.controllers;

import com.bongs20.growbuddy.Main;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;

public class AdminLoginController {

    @FXML
    private PasswordField passwordInput;

    @FXML
    private Label errorLabel;

    @FXML
    public void handleBack(ActionEvent event) {
        Main.navigateToDeviceSelection();
    }

    @FXML
    public void handleLogin(ActionEvent event) {
        String password = passwordInput.getText();
        if ("admin123".equals(password)) {
            errorLabel.setVisible(false);
            System.out.println("Admin login successful.");
            Main.navigateToAdminDashboard();
        } else {
            errorLabel.setText("Password Admin salah!");
            errorLabel.setVisible(true);
        }
    }
}
