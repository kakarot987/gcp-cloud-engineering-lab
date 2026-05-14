package com.example.hellocloudrun;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Spring Boot application class for Hello Cloud Run.
 *
 * This application demonstrates a simple REST API deployed to Google Cloud Run,
 * showcasing serverless container deployment patterns.
 */
@SpringBootApplication
public class HelloCloudRunApplication {

    public static void main(String[] args) {
        SpringApplication.run(HelloCloudRunApplication.class, args);
    }
}
