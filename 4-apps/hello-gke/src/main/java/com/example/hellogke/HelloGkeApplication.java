package com.example.hellogke;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Spring Boot application class for Hello GKE.
 *
 * This application demonstrates a containerized microservice deployed to
 * Google Kubernetes Engine, showcasing Kubernetes deployment patterns
 * and container orchestration.
 */
@SpringBootApplication
public class HelloGkeApplication {

    public static void main(String[] args) {
        SpringApplication.run(HelloGkeApplication.class, args);
    }
}
