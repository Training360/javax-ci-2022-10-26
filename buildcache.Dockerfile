FROM eclipse-temurin:17-jdk as builder
WORKDIR app
COPY pom.xml mvnw .
COPY .mvn .mvn
RUN ./mvnw package --fail-never
COPY . .
RUN ./mvnw package
