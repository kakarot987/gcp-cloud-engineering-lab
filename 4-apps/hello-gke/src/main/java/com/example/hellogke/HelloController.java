package com.example.hellogke;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * REST Controller for Hello GKE application.
 *
 * Provides endpoints demonstrating:
 * - RESTful API design
 * - Path and query parameters
 * - Kubernetes environment integration
 * - Health checks and monitoring
 * - Configuration management
 */
@RestController
@RequestMapping("/api/v1")
public class HelloController {

    @Value("${spring.application.name:hello-gke}")
    private String applicationName;

    @Value("${app.version:1.0.0}")
    private String appVersion;

    @Value("${app.environment:development}")
    private String environment;

    @Value("${app.message:Hello from Kubernetes!}")
    private String defaultMessage;

    /**
     * Basic greeting endpoint.
     *
     * @return A greeting message with application info
     */
    @GetMapping("/hello")
    public ResponseEntity<Map<String, Object>> hello() {
        Map<String, Object> response = createBaseResponse();
        response.put("message", defaultMessage);
        response.put("platform", "Google Kubernetes Engine");

        return ResponseEntity.ok(response);
    }

    /**
     * Personalized greeting endpoint.
     *
     * @param name The name to greet
     * @return Personalized greeting
     */
    @GetMapping("/hello/{name}")
    public ResponseEntity<Map<String, Object>> helloName(@PathVariable String name) {
        Map<String, Object> response = createBaseResponse();
        response.put("message", String.format("Hello, %s! Welcome to Kubernetes!", name));
        response.put("greeted_person", name);

        return ResponseEntity.ok(response);
    }

    /**
     * Greeting with repetition.
     *
     * @param name The name to greet
     * @param count Number of times to repeat (1-10)
     * @return Repeated greeting
     */
    @GetMapping("/hello/repeat")
    public ResponseEntity<Map<String, Object>> helloRepeat(
            @RequestParam(defaultValue = "World") String name,
            @RequestParam(defaultValue = "1") @Min(1) @Max(10) int count) {

        Map<String, Object> response = createBaseResponse();
        String message = String.format("Hello, %s!", name);
        String repeatedMessage = message.repeat(count).trim();

        response.put("message", repeatedMessage);
        response.put("repetitions", count);
        response.put("greeted_person", name);

        return ResponseEntity.ok(response);
    }

    /**
     * Environment and application information.
     *
     * @return Detailed application and environment info
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> response = createBaseResponse();
        response.put("application", applicationName);
        response.put("version", appVersion);
        response.put("environment", environment);
        response.put("platform", "Google Kubernetes Engine");

        // Kubernetes environment variables
        Map<String, String> k8sEnv = new HashMap<>();
        k8sEnv.put("HOSTNAME", System.getenv("HOSTNAME"));
        k8sEnv.put("KUBERNETES_SERVICE_HOST", System.getenv("KUBERNETES_SERVICE_HOST"));
        k8sEnv.put("KUBERNETES_SERVICE_PORT", System.getenv("KUBERNETES_SERVICE_PORT"));

        response.put("kubernetes", k8sEnv);

        // JVM information
        Map<String, String> jvm = new HashMap<>();
        jvm.put("java.version", System.getProperty("java.version"));
        jvm.put("java.vendor", System.getProperty("java.vendor"));
        jvm.put("os.name", System.getProperty("os.name"));
        jvm.put("os.arch", System.getProperty("os.arch"));

        response.put("jvm", jvm);

        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint for Kubernetes.
     *
     * @return Health status for liveness and readiness probes
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = createBaseResponse();
        response.put("status", "UP");
        response.put("service", applicationName);

        Map<String, String> checks = new HashMap<>();
        checks.put("application", "UP");
        checks.put("readiness", "READY");
        checks.put("liveness", "ALIVE");
        checks.put("database", "UP"); // Simulated

        response.put("checks", checks);

        return ResponseEntity.ok(response);
    }

    /**
     * Readiness check endpoint.
     *
     * @return Readiness status for Kubernetes probes
     */
    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> ready() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "READY");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        response.put("service", applicationName);

        return ResponseEntity.ok(response);
    }

    /**
     * Create base response with common fields.
     *
     * @return Base response map
     */
    private Map<String, Object> createBaseResponse() {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        response.put("service", applicationName);
        response.put("version", appVersion);
        return response;
    }
}
