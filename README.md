# Java CI/CD képzésen

## Projekt létrehozása

```shell
git clone https://github.com/Training360/javax-ci-2022-10-26
xcopy /e /i javax-ci-2022-10-26 employees
```

## Build

```shell
set JAVA_HOME=C:\Program Files\Java\jdk-17.0.4.1
cd employees
mvnw package
```

Ha proxy mögött vagyunk, akkor a Maven `$HOME\.m2\settings.xml`-jét kell szerkeszteni:

https://maven.apache.org/guides/mini/guide-proxies.html

Gradle esetén:

```shell
gradlew build
```

## Futtatás

```shell
java -jar target\employees-1.0-SNAPSHOT.jar
```

Az alkalmazás elérhető a http://localhost:8080/ címen.

## Függőségek

```shell
mvnw dependency:tree
mvnw versions:display-dependency-updates
```

## Docker indítása

Adminisztrátori parancssorban:

```shell
net localgroup docker-users %USERDOMAIN%\%USERNAME% /add
```

Kijelentkezés, visszajelentkezés, Docker Desktop elindítása menüből

Kipróbálni:

```shell
docker run hello-world
```

## Nexus indítása

```shell
docker run --name nexus --detach --publish 8091:8081 --publish 8092:8082 --volume nexus-data:/nexus-data sonatype/nexus3
```

## Letöltés Nexusról, proxy-n át

`$HOME\.m2\settings.xml` fájl létrehozása a következő tartalommal:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
   <mirrors>
    <mirror>
      <id>central</id>
      <name>central</name>
      <url>http://localhost:8091/repository/maven-public/</url>
      <mirrorOf>*</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

* A `$HOME\.m2\repository\antlr` könyvtár törlése.
* `mvnw package` parancs futtatása

## Tesztlefedettség

A `pom.xml`-t kell kiegészíteni a `jacoco-maven-plugin`-nal.

A `mvnw package` parancs kiadása után létrejön a `target/site/jacoco/index.html` riport.

## Integrációs tesztelés

Az `src\test\java\employees\EmployeesControllerRestAssuredIT` és `src\test\resources\employee-dto.json` átmásolása
a megfelelő könyvtárba.

A `pom.xml`-t kell kiegészíteni a `maven-failsafe-plugin`-nal.

Majd `mvnw verify` parancsot kell kiadni.

## Docker parancsok

```shell
docker run -d -p 80:80 nginx
docker ps
docker stop 37
docker start 37
docker logs -f 37
docker stop 37
docker rm 37
docker run -d -p 80:80 --name my-nginx nginx
docker exec -it my-nginx bash
docker exec -it my-nginx cat /etc/nginx/nginx.conf  
docker rm --force  my-nginx 
docker run -d -p 80:80 --name my-nginx -v C:\Users\T360-kk-CICD-o\javax-ci-2022-10-26\html:/usr/share/nginx/html:ro nginx
```

## Adatbázis elindítása

```shell
docker run -d -e MARIADB_DATABASE=employees -e MARIADB_USER=employees  -e MARIADB_PASSWORD=employees -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes -p 3306:3306 --name employees-mariadb mariadb
```

## Adatbázishoz kapcsolódás

```shell
set SPRING_DATASOURCE_URL=jdbc:mariadb://localhost/employees
set SPRING_DATASOURCE_USERNAME=employees
set SPRING_DATASOURCE_PASSWORD=employees
java -jar target\employees-1.0-SNAPSHOT.jar
docker exec -it employees-mariadb mysql employees
select * from employees;
```

## Integrációs tesztek futtatása valós adatbázison

A `pom.xml` állományt kiegészítjük a `maven-failsafe-plugin`-nél
a `configuration` taggel.

## Image létrehozása

Létrehoztuk a `Dockerfile` fájlt, a következő tartalommal:

```
FROM eclipse-temurin:17-jdk
WORKDIR app
COPY target/*.jar employees.jar
ENTRYPOINT ["java", "-jar", "employees.jar"]
```

```shell
docker build -t employees .
docker run -d -p 8080:8080 --name my-employees employees
```

## Konténerek saját hálózatban

```shell
docker network create employees-net
docker run -d -e MARIADB_DATABASE=employees -e MARIADB_USER=employees  -e MARIADB_PASSWORD=employees -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes -p 3307:3306 --network employees-net --name employees-app-mariadb mariadb
docker run -d -p 8081:8080 -e SPRING_DATASOURCE_URL=jdbc:mariadb://employees-app-mariadb/employees -e SPRING_DATASOURCE_USERNAME=employees -e SPRING_DATASOURCE_PASSWORD=employees --network employees-net --name my-app-employees employees
```

# Két konténer futtatása egy paranccsal

Az `employees-app` könyvtár átmásolása, ebben a könyvtárban kiadni:

```shell
docker compose up
```

Nagyon vigyázni kell a `wait-for-it.sh`-ban lévő sorvége jelekre, hogy Linuxosak maradjanak.

## Docker layers

* Átmásolni a `layers.Dockerfile` fájlt.
* Kiadni a `docker build -t leayered-employees -f layers.Dockerfile .` parancsot
* Módosítani a `src\main\java\employees\controller\EmployeesController.java` fájlt: 28-as sor, idézőjelek közé egy pont
* `mvnw package`
* Majd újra kiadni a `docker build -t leayered-employees -f layers.Dockerfile .` parancsot

## Build a Docker konténerben

* Vigyázz! Az `mvnw` szkript Linuxos sorvége jeleket tartalmazzon!
* `build.Dockerfile` átmásolása
* Parancs a főkönyvtárban:

```shell
docker build -t built-employees -f build.Dockerfile --progress=plain .
```

## Függőségek cache-elése

* Át kell másolni a `buildcache.Dockerfile` fájlt
* Majd

```shell
docker build -t builtcache-employees -f buildcache.Dockerfile --progress=plain .
```

* Controller módosítása

* Utána újra az előző parancs.

Másodjára már nem húz le annyi függőséget.

## Postman teszteset

```javascript
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});
pm.test("Check name", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.name).to.eql("Jack Doe");
});
```

## Futtatás

* `e2e` könyvtár hasonlóan nézzen ki, mint az oktatónál
* A következő parancsot kell kiadni az `e2e` könyvtárban (a docker compose mindig az aktuális könyvtárban keresi a `docker-compose.yaml` fájlt)

```shell
docker compose up --abort-on-container-exit
```

## SonarQube

```shell
docker run --name sonarqube -d -p 9000:9000 sonarqube:lts
```

Alapértelmezett felhasználónév és jelszó: `admin` / `admin`
Meg kell változtatni, ne ugyanarra, és talán kell bele kis- és nagybetű, vagy szám.

Token létrehozása: (User) Administrator (jobb felső sarok) / My Account / Security / Generate tokens

Elemzés futtatása (az előbb generált saját tokennel):

```shell
mvnw sonar:sonar -Dsonar.login=650166f758eaeb54f...
```

[SonarScanner for Maven plugin dokumentáció](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)

## Bejelentkezés Nexusba

Elérhető a következő címen: http://localhost:8091

Admin jelszó elérése:

```shell
docker exec -it nexus cat /nexus-data/admin.password
```

## Feltöltés Nexusba

* `pom.xml`-be felvenni, pl  `properties` után:


```xml
	<distributionManagement>
		<snapshotRepository>
			<id>nexus-snapshots</id>
			<url>http://localhost:8091/repository/maven-snapshots/</url>
		</snapshotRepository>
	</distributionManagement>
```

* Beállítani a jelszót a `$HOME\.m2\settings.xml` fájlban a `settings` alá:

```xml
<servers>
  <server>
    <id>nexus-snapshots</id>
    <username>admin</username>
    <password>admin</password>
  </server>
</servers>
```

* `mvnw deploy` parancs kiadása

## Release esetén

`pom.xml`-ben:

* Verzió `SNAPSHOT` szó törlés
* `repository` tag elhelyezése
* Jelszó beállítása a `settings.xml` fájlban

## Docker image Nexusba

* Create Docker repository
* HTTP `8082` port
* Adminisztrációs felületen: Nexus Security / Realms tabon: Docker Bearer Token Realm hozzáadása

```shell
docker login localhost:8092
docker tag employees localhost:8092/employees:1.0.0
docker push localhost:8092/employees:1.0.0
```

## Telepítés Kubernetesre

Vigyázz, a pod nevénél a saját podod nevét használd!

```shell
kubectl version
kubectl apply -f mariadb-secrets.yaml
kubectl get secrets
kubectl apply -f mariadb-deployment.yaml
kubectl get pods
kubectl logs -f mariadb-85cc8b5b94-ljdtg
kubectl apply -f employees-secrets.yaml
kubectl apply -f employees-deployment.yaml
kubectl get pods
docker tag employees employees:1.0.0
  # employees-deployment.yaml fájl kiegészítése: - image: employees:1.0.0
kubectl delete -f employees-deployment.yaml
kubectl apply -f employees-deployment.yaml
kubectl get pods
kubectl logs -f employees-app-8695c558-g4p6p
kubectl port-forward svc/employees-app 8080:8080
```

# Monitorozás

`pom.xml` bővítése a `spring-boot-starter-test` előtt:

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<dependency>
  <groupId>io.micrometer</groupId>
  <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

A `src\main\resources\application.properties` végére írjuk be:

```
management.endpoints.web.exposure.include = prometheus
```

Következő parancsok:

```shell
mvnw package
docker build -t employees:1.1.0 .
```

Az `employees-deployment.yaml` fájlban átírni a verziót `1.0.0`-ról `1.1.0`-ra.

```shell
cd deployments
kubectl apply -f employees-deployment.yaml
kubectl get pods
kubectl port-forward svc/employees-app 8080:8080 
```

## Prometheus, Grafana

```shell
kubectl apply -f prometheus-deployment.yaml 
kubectl apply -f grafana-deployment.yaml
```

Külön parancssorokban:

```shell
kubectl port-forward svc/prometheus 9090:9090
kubectl port-forward svc/grafana 3000:3000
kubectl port-forward svc/employees-app 8080:8080
```

http://localhost:3000

Grafana felhasználónév/jelszó: `admin` / `admin`

## GitLab

```shell
cd gitlab
docker compose up -d
```

## Git

```shell
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

A projekt főkönyvtárában!

```shell
git init
git add .
git commit -m "Init"
```

## GitLab

```shell
docker exec -it gitlab-gitlab-1 grep "Password:" /etc/gitlab/initial_root_password
```

Felhasználónév: `root`

```shell
git remote add origin http://localhost/gitlab-instance-5169068c/employees.git
git remote remove origin
git remote add origin http://localhost/gitlab-instance-5169068c/employees.git
git push origin master
```

Menu / Admin / Overview / Runners / Register an instance runner

Saját tokennel!

```
docker exec -it gitlab-gitlab-runner-1 gitlab-runner register --non-interactive --url http://gitlab-gitlab-1 --registration-token q_bzYNcE1-W4PGyD9Myr --executor docker --docker-image docker:latest --docker-network-mode gitlab_default --clone-url http://gitlab-gitlab-1 --docker-volumes /var/run/docker.sock:/var/run/docker.sock
```
