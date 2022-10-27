FROM eclipse-temurin:17-jdk as builder
WORKDIR app
COPY . .
RUN ./mvnw package

FROM eclipse-temurin:17-jdk
WORKDIR app
COPY --from=builder app/target/*.jar ./employees.jar
ENTRYPOINT ["java", "-jar", "employees.jar"]
