
class: inverse, center, middle

# GitLab

---

## GitLab CI

* CI/CD megoldás
* Konkurencia: Jenkins, GitHub Actions, Travis, Circle CI
* GitLab része
  * Git
  * Wiki
  * Issue tracking
  * Stb.
* Külön komponens: GitLab Runner

---

## GitLab infrastruktúra elindítása

```
cd gitlab
docker compose up -d
docker compose logs -f
docker exec -it gitlab-gitlab-1 grep "Password:" /etc/gitlab/initial_root_password
```

http://localhost

Bejelentkezés: `root` felhasználóval

Változtassuk meg a jelszót!

---

## Runner regisztráció

Menu / Admin / Overview / Runners / Register an instance runner

```
docker exec -it gitlab-gitlab-runner-1 gitlab-runner register --non-interactive --url http://gitlab-gitlab-1 --registration-token WbuAz4dc5BB4YYHWpA1f --executor docker --docker-image docker:latest --docker-network-mode gitlab_default --clone-url http://gitlab-gitlab-1 --docker-volumes /var/run/docker.sock:/var/run/docker.sock
```

Ha valami szétesne:

```shell
docker exec -it gl-gitlab-runner-1 gitlab-runner verify
```

---

## Git push

Credential manager

`localhost`!

git remote add origin http://localhost/gitlab-instance-e376da84/demo-service.git

---

## GitLab CI

* Pipeline egy `.gitlab-ci.yml` fájl
* Job: utasítások leírására
* Stage: a jobokat milyen sorrendben kell végrehajtani


## First pipeline

`.gitlab-ci.yml`

```
image: eclipse-temurin:17

stages:
  - build

build-job:
  stage: build
  script:
    - echo "Hello Pipeline"
```

CI/CD / Pipelines menüpont

---

## Pipeline editor

* CI/CD / Editor menüpont
* _This GitLab CI configuration is valid._

## First Java pipeline


```yaml
image: eclipse-temurin:17

stages:
  - build

build-job:
  stage: build
  script:
    - echo "Hello Pipeline"
    - ./mvnw package
```

# Pipeline cache

```yaml
variables:
   MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"

cache:
  paths:
    - .m2/repository
```

Következő forráskód módosítás:

* Restoring cache
* Saving cache for successful job

# Pipeline 3 stage-gel

```yaml
variables:
   MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"

cache:
  paths:
    - .m2/repository

image: eclipse-temurin

stages:
  - build
  - test
  - image

build-job:
  stage: build
  script:
    - echo "Hello Pipeline"
    - ./mvnw package
  artifacts:
    paths:
      - target

test-job:
  stage: test
  script:
    - ./mvnw verify

image-job:
  stage: image
  image: docker:20.10.11
  script:
    - docker build -t hello-world-java:0.0.1 .
```

* Visualize

---

# Job artifact

```yaml
build-job:
  stage: build
  script:
    - echo "Hello Pipeline"
    - ./mvnw package
  artifacts:
    paths:
      - target/*.jar
```

* Download artifacts

---

# Variables

* Settings / CI/CD / Variables / Add variable

```yaml
build-job:
  stage: build
  script:
    - echo "Hello Pipeline"
    - echo $TMP_USERNAME
```

---

# Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: demo-service
  name: demo-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-service
  template:
    metadata:
      labels:
        app: demo-service
    spec:
      containers:
      - image: demo-service:0.0.1
        name: demo-service
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: demo-service
  name: demo-service
spec:
  ports:
  - name: 8080-8080
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: demo-service
  type: ClusterIP
```

```yaml
deploy-job:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl apply -f deployment.yaml
```