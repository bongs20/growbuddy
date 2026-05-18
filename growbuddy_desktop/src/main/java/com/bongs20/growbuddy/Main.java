package com.bongs20.growbuddy;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.net.URL;

public class Main extends Application {

    private static Stage primaryStage;

    @Override
    public void start(Stage stage) throws Exception {
        primaryStage = stage;
        
        URL fxmlLocation = getClass().getResource("/fxml/SplashScreen.fxml");
        if (fxmlLocation == null) {
            System.err.println("Cannot find SplashScreen.fxml. Ensure it is in src/main/resources/fxml/");
            return;
        }

        Parent root = FXMLLoader.load(fxmlLocation);
        Scene scene = new Scene(root, 1200, 800); // Desktop aspect ratio
        
        stage.setTitle("GrowBuddy Desktop");
        stage.setScene(scene);
        stage.show();
    }

    public static void navigateToDashboard(String deviceId) {
        try {
            if (deviceId.startsWith("demo_")) {
                com.bongs20.growbuddy.services.DemoSimulatorService.getInstance().start(deviceId);
            } else {
                com.bongs20.growbuddy.services.DemoSimulatorService.getInstance().stop();
            }

            FXMLLoader loader = new FXMLLoader(Main.class.getResource("/fxml/MainLayout.fxml"));
            Parent root = loader.load();
            
            com.bongs20.growbuddy.controllers.MainLayoutController controller = loader.getController();
            controller.initData(deviceId);

            Scene scene = new Scene(root, 1200, 800);
            primaryStage.setScene(scene);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void navigateToDeviceSelection() {
        try {
            com.bongs20.growbuddy.services.DemoSimulatorService.getInstance().stop();

            FXMLLoader loader = new FXMLLoader(Main.class.getResource("/fxml/DeviceSelection.fxml"));
            Parent root = loader.load();
            Scene scene = new Scene(root, 1200, 800);
            primaryStage.setScene(scene);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void navigateToAdminLogin() {
        try {
            FXMLLoader loader = new FXMLLoader(Main.class.getResource("/fxml/AdminLogin.fxml"));
            Parent root = loader.load();
            Scene scene = new Scene(root, 1200, 800);
            primaryStage.setScene(scene);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void navigateToCalibration(String deviceId) {
        try {
            FXMLLoader loader = new FXMLLoader(Main.class.getResource("/fxml/Calibration.fxml"));
            Parent root = loader.load();
            
            com.bongs20.growbuddy.controllers.CalibrationController controller = loader.getController();
            controller.initData(deviceId);
            
            Scene scene = new Scene(root, 1200, 800);
            primaryStage.setScene(scene);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static void navigateToAdminDashboard() {
        try {
            FXMLLoader loader = new FXMLLoader(Main.class.getResource("/fxml/AdminDashboard.fxml"));
            Parent root = loader.load();
            Scene scene = new Scene(root, 1200, 800);
            primaryStage.setScene(scene);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static Stage modalStage;

    public static void showModal(String fxml, String deviceId) {
        try {
            if (modalStage != null && modalStage.isShowing()) {
                modalStage.close();
            }
            FXMLLoader loader = new FXMLLoader(Main.class.getResource(fxml));
            Parent root = loader.load();
            
            Object controller = loader.getController();
            if (controller instanceof com.bongs20.growbuddy.controllers.WateringConfirmationController) {
                ((com.bongs20.growbuddy.controllers.WateringConfirmationController) controller).initData(deviceId);
            } else if (controller instanceof com.bongs20.growbuddy.controllers.WateringProgressController) {
                ((com.bongs20.growbuddy.controllers.WateringProgressController) controller).initData(deviceId);
            } else if (controller instanceof com.bongs20.growbuddy.controllers.WateringResultController) {
                ((com.bongs20.growbuddy.controllers.WateringResultController) controller).initData(deviceId);
            } else if (controller instanceof com.bongs20.growbuddy.controllers.EditProfileController) {
                ((com.bongs20.growbuddy.controllers.EditProfileController) controller).initData(deviceId);
            } else if (controller instanceof com.bongs20.growbuddy.controllers.EditPumpDurationController) {
                ((com.bongs20.growbuddy.controllers.EditPumpDurationController) controller).initData(deviceId);
            }
            
            modalStage = new Stage();
            modalStage.initOwner(primaryStage);
            modalStage.initModality(javafx.stage.Modality.WINDOW_MODAL);
            Scene scene = new Scene(root);
            modalStage.setScene(scene);
            modalStage.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void closeModal() {
        if (modalStage != null) {
            modalStage.close();
            modalStage = null;
        }
    }

    @Override
    public void stop() throws Exception {
        com.bongs20.growbuddy.services.DemoSimulatorService.getInstance().stop();
        super.stop();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
