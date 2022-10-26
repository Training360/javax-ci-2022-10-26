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

## Git

```shell
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```