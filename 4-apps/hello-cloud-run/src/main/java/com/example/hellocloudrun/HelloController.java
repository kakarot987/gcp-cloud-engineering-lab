package com.example.hellocloudrun;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * REST Controller for Hello Cloud Run application.
 *
 * Provides endpoints demonstrating:
 * - Basic greeting API
 * - Environment information
 * - Health status
 * - Serverless deployment patterns
 */
@RestController
@RequestMapping("/api")
public class HelloController {

    @Value("${spring.application.name:hello-cloud-run}")
    private String applicationName;

    @Value("${app.version:1.0.0}")
    private String appVersion;

    /**
     * Basic greeting endpoint.
     *
     * @return A friendly greeting message
     */
    @GetMapping("/hello")
    public ResponseEntity<Map<String, Object>> hello() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello from Google Cloud Run!");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        response.put("service", "Cloud Run");
        response.put("version", appVersion);

        return ResponseEntity.ok(response);
    }

    /**
     * Environment information endpoint.
     *
     * @return Information about the runtime environment
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", applicationName);
        response.put("version", appVersion);
        response.put("platform", "Google Cloud Run");
        response.put("java.version", System.getProperty("java.version"));
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));

        // Environment variables (safely exposed)
        Map<String, String> env = new HashMap<>();
        env.put("PORT", System.getenv("PORT"));
        env.put("K_SERVICE", System.getenv("K_SERVICE"));
        env.put("K_REVISION", System.getenv("K_REVISION"));
        env.put("K_CONFIGURATION", System.getenv("K_CONFIGURATION"));

        response.put("environment", env);

        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint for Cloud Run.
     *
     * @return Health status
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        response.put("service", applicationName);
        response.put("checks", Map.of(
            "application", "UP",
            "readiness", "READY"
        ));

        return ResponseEntity.ok(response);
    }
}
