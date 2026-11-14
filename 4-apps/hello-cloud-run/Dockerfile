# Maven is provided by the builder image; no mvnw wrapper is required.
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B -ntp clean verify

FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S -g 1001 appgroup && adduser -S -u 1001 -G appgroup appuser
WORKDIR /app
COPY --from=builder /app/target/*.jar /app/app.jar
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD wget -q -O /dev/null http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
