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

Létrehoztuk a `Dockerfile` fájlt.

```shell
docker build -t employees .
```

## Git

```shell
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```