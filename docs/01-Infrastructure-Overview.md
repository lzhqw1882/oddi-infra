# 🏗️ ODDI Infrastructure Architecture Overview

> **위치:** `apps/oddi-infra/docs/01-Infrastructure-Overview.md`  
> **최종 수정일:** 2026-11-13  
> **관련 문서:** [[02-Local-Development-Setup]]

---

## 1. 개요 (Overview)

**오디 (ODDI)** 인프라는 **로컬 개발 환경 (Local Docker PostgreSQL)** 과 **상용 데이터 계층 (Supabase Cloud)** 으로 나뉜다.

애플리케이션은 저장소 세 개로 나뉜다.

- **프론트 앱:** Flutter (`oddi-app`)
- **프론트용 API:** NestJS (`oddi-backend`)
- **백엔드용 API:** Spring Boot (`oddi-backend-admin`). 이후 NestJS로 변경 예정

애플리케이션 런타임은 Kubernetes로 올리지 않고, Argo CD로 동기화하지 않는다. 이 저장소의 운영 절차는 로컬 데이터베이스와 Supabase 연동까지다.

---

## 2. 구성 (Layout)

```mermaid
graph TD
    subgraph Local Development Environment
        App[Flutter App - oddi-app] --> FrontApi[Front API - NestJS oddi-backend - Port 4001]
        FrontApi --> LocalDB[(Local Docker PostgreSQL - Port 5432)]
        BackendApi[Backend API - Spring Boot oddi-backend-admin - Port 9090] --> LocalDB
    end

    subgraph Production Data - Supabase
        SupabaseDB[(Supabase Managed PostgreSQL)]
        SupabaseAuth[Supabase Auth - Google, Apple, Kakao]
        SupabaseStorage[Supabase Storage - review-images]
    end
```

로컬 서비스는 각 저장소에서 직접 실행하고, 같은 로컬 PostgreSQL을 사용한다. 상용 환경의 PostgreSQL, 인증, 스토리지는 Supabase 프로젝트가 담당한다.

---

## 3. 구성요소별 역할

| 구성요소 | 저장소 | 로컬 | 상용 |
| :--- | :--- | :--- | :--- |
| **프론트 앱** | `oddi-app` | Flutter (`flutter run`) | App Store / Google Play |
| **프론트용 API** | `oddi-backend` | NestJS (`localhost:4001`) | 이 저장소의 배포 대상이 아님 |
| **백엔드용 API** | `oddi-backend-admin` | Spring Boot (`localhost:9090`). 이후 NestJS | 이 저장소의 배포 대상이 아님 |
| **`database`** | `oddi-infra` | Docker Container (`oddi-postgres`:5432) | Supabase Cloud Managed PostgreSQL |
| **`auth / storage`** | Supabase | Supabase Dev Project | Supabase Prod Project (Google, Apple, Kakao) |
