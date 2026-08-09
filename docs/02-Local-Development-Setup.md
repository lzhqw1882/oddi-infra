# 💻 Local Development Infrastructure Setup Guide

> **위치:** `apps/oddi-infra/docs/02-Local-Development-Setup.md`  
> **최종 수정일:** 2026-08-02  
> **관련 문서:** [[01-Infrastructure-Overview]]

---

## 1. 개요

본 문서는 로컬 개발 환경에서 **Docker PostgreSQL**을 구동하고, `apps/database/schema.sql` 스크립트를 통한 **자동 DB 초기화**, 그리고 Node.js `v24.18.1` 기반의 프론트엔드 및 백엔드 서비스를 실행하는 가이드를 다룹니다.

---

## 2. Docker PostgreSQL 셋팅 (`docker-compose.yml`)

로컬 DB는 프로젝트 루트의 `docker-compose.yml`을 통해 **PostGIS 16** 컨테이너로 구동됩니다.

### 2.1 설정 파일 구조
```yaml
# docker-compose.yml
services:
  db:
    image: postgis/postgis:16-3.4
    platform: linux/amd64
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
      - ./apps/database/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql

volumes:
  oddi_postgres_data:
    driver: local
```

### 2.2 로컬 DB 구동 명령어

```bash
# 1. 로컬 DB 컨테이너 실행 (백그라운드)
docker-compose up -d

# 2. DB 구동 상태 및 포트(5432) 바인딩 확인
docker ps

# 3. DB 접속 테스트 (psql 또는 DBeaver 등)
# Host: localhost, Port: 5432, DB: oddi, User: oddi, Password: oddi2026password*
```

---

## 3. 로컬 마이크로서비스 실행 가이드

### 3.1 Node.js 런타임 세팅 (`nvm`)
```bash
# Node.js 24.18.1 버전 세팅
nvm install 24.18.1
nvm alias default 24.18.1
nvm use default
```

### 3.2 백엔드 API (`apps/front-api`) 실행
```bash
cd apps/front-api
npm install
npm run start:dev
# http://localhost:4000 에서 API 대기
```

### 3.3 프론트엔드 (`apps/oddi`) 실행
```bash
cd apps/oddi
npm install
npm run dev
# http://localhost:3000 에서 웹 서비스 확인
```
