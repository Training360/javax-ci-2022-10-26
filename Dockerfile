FROM eclipse-temurin:17-jdk
WORKDIR app
COPY target/*.jar employees.jar
ENTRYPOINT ["java", "-jar", "employees.jar"]