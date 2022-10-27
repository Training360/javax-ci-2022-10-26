FROM eclipse-temurin:17-jdk as builder
WORKDIR app
COPY target/*.jar employees.jar
RUN java -Djarmode=layertools -jar employees.jar extract

FROM eclipse-temurin:17-jdk
WORKDIR app
COPY --from=builder app/dependencies/ ./
COPY --from=builder app/spring-boot-loader/ ./
COPY --from=builder app/snapshot-dependencies/ ./
COPY --from=builder app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
