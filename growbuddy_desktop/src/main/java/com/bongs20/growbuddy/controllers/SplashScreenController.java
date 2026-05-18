package com.bongs20.growbuddy.controllers;

import javafx.animation.KeyFrame;
import javafx.animation.KeyValue;
import javafx.animation.Timeline;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.ProgressBar;
import javafx.scene.image.ImageView;
import javafx.stage.Stage;
import javafx.util.Duration;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class SplashScreenController implements Initializable {

    @FXML
    private ProgressBar progressBar;

    @FXML
    private ImageView illustrationImage;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        // Animate the progress bar
        Timeline timeline = new Timeline(
                new KeyFrame(Duration.ZERO, new KeyValue(progressBar.progressProperty(), 0)),
                new KeyFrame(Duration.seconds(2), new KeyValue(progressBar.progressProperty(), 1.0))
        );
        
        timeline.setOnFinished(e -> loadNextScreen());
        timeline.play();
    }

    private void loadNextScreen() {
        Platform.runLater(() -> {
            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/fxml/AutoLogin.fxml"));
                Parent root = loader.load();
                
                Stage stage = (Stage) progressBar.getScene().getWindow();
                Scene scene = new Scene(root, 450, 800);
                stage.setScene(scene);
                stage.show();
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
    }
}
