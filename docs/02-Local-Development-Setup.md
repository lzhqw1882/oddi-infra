# 💻 Local Development Infrastructure Setup Guide

> **위치:** `apps/oddi-infra/docs/02-Local-Development-Setup.md`  
> **최종 수정일:** 2026-11-13  
> **관련 문서:** [[01-Infrastructure-Overview]]

---

## 1. 개요

본 문서는 로컬 개발 환경에서 **Docker PostgreSQL**을 구동하고, `database/schema.sql`과 `database/seed.sql`로 DB를 초기화한 뒤 각 저장소의 서비스를 실행하는 절차를 다룬다.

서비스와 저장소는 나뉘어 있다.

- **프론트 앱:** Flutter, `oddi-app`
- **프론트용 API:** NestJS, `oddi-backend` (`localhost:4001`)
- **백엔드용 API:** Spring Boot, `oddi-backend-admin` (`localhost:9090`). 이후 NestJS로 변경 예정

---

## 2. Docker PostgreSQL 셋팅 (`docker-compose.yml`)

로컬 DB는 `oddi-infra` 루트의 `docker-compose.yml`을 통해 **PostGIS 16** 컨테이너로 구동된다.

### 2.1 설정 파일 구조
```yaml
# docker-compose.yml
services:
  db:
    image: postgis/postgis:16-3.4
    container_name: oddi-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: oddi
      POSTGRES_PASSWORD: oddi2026password*
      POSTGRES_DB: oddi
    ports:
      - "5432:5432"
    volumes:
      - oddi_postgres_data:/var/lib/postgresql/data
      - ./database/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql:ro
      - ./database/seed.sql:/docker-entrypoint-initdb.d/02-seed.sql:ro

volumes:
  oddi_postgres_data:
    driver: local
```

### 2.2 로컬 DB 구동 명령어

```bash
# 1. oddi-infra 루트에서 로컬 DB 컨테이너 실행
docker-compose up -d

# 2. DB 구동 상태 및 포트(5432) 바인딩 확인
docker ps

# 3. DB 접속 테스트 (psql 또는 DBeaver 등)
# Host: localhost, Port: 5432, DB: oddi, User: oddi, Password: oddi2026password*
```

---

## 3. 로컬 서비스 실행

### 3.1 프론트용 API (`oddi-backend`, NestJS)

Node.js `v24.18.1`을 사용한다.

```bash
nvm install 24.18.1
nvm alias default 24.18.1
nvm use default

cd ../oddi-backend
npm install
npm run start:dev
# http://localhost:4001
```

### 3.2 백엔드용 API (`oddi-backend-admin`, Spring Boot)

Java 21. 이후 이 API는 NestJS로 바꾼다.

```bash
cd ../oddi-backend-admin
./gradlew bootRun
# http://localhost:9090
```

### 3.3 프론트 앱 (`oddi-app`, Flutter)

```bash
cd ../oddi-app
flutter pub get
flutter run
```
