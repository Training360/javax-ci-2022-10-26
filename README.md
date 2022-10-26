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

## Git

```shell
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```