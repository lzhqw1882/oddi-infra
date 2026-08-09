# 🏗️ ODDI Infrastructure Architecture Overview

> **위치:** `apps/oddi-infra/docs/01-Infrastructure-Overview.md`  
> **최종 수정일:** 2026-08-02  
> **관련 문서:** [[02-Local-Development-Setup]], [[03-Kubernetes-and-Kustomize-Guide]], [[04-ArgoCD-GitOps-Guide]]

---

## 1. 개요 (Overview)

**오디 (ODDI)** 서비스의 인프라스트럭처는 개발 효율성과 상용 환경의 안정성을 위해 **로컬 개발 환경 (Local Docker)**과 **상용 환경 (Production Supabase + K8s / Argo CD GitOps)**으로 완전히 이원화되어 운영됩니다.

---

## 2. 전체 이원화 아키텍처 (Dual Architecture)

```mermaid
graph TD
    subgraph Local Development Environment
        DevBrowser[Local Web Browser] --> NextDev[Next.js Dev Server - Port 3000]
        NextDev --> NestDev[NestJS front-api - Port 4000]
        NestDev --> LocalDB[(Local Docker PostgreSQL - Port 5432)]
        BatchDev[NestJS oddi-batch] --> LocalDB
    end

    subgraph Production Environment (Kubernetes / Argo CD)
        UserClient([Prod User Web/Mobile]) --> Ingress[NGINX Ingress Controller - oddi.kr]
        Ingress -- /api --> ApiService[NestJS front-api Pods - Replicas 2]
        Ingress -- / --> WebService[Next.js front-web Pods - Replicas 2]
        
        CronJob[oddi-batch CronJob - Monthly] -- Scrape --> External[Numbeo / Google Travel]
        CronJob -- Upsert --> SupabaseDB[(Supabase Managed PostgreSQL)]
        ApiService -- DB Query --> SupabaseDB
        
        WebService -- Auth --> SupabaseAuth[Supabase Auth - Google, Apple, Kakao]
        WebService -- Upload --> SupabaseStorage[Supabase Storage - review-images]
        
        ArgoCD[Argo CD Controller] -- GitOps Sync --> K8sOverlays[k8s/overlays/prod]
    end
```

---

## 3. 서비스별 인프라 역할 분담

| 마이크로서비스 | 런타임 / 스택 | 로컬 개발 구성 (Local) | 상용 배포 구성 (Production) |
| :--- | :--- | :--- | :--- |
| **`front-web`** | Next.js 15 App Router | `npm run dev` (`localhost:3000`) | K8s Deployment (`10-front-web.yaml`), Replicas 2 |
| **`front-api`** | NestJS Backend API | `npm run start:dev` (`localhost:4000`) | K8s Deployment (`20-front-api.yaml`), Replicas 2 |
| **`oddi-batch`** | NestJS Scraper Engine | 수동 로컬 실행 스크립트 | K8s CronJob (`30-oddi-batch-cronjob.yaml`), 월간 자동 실행 |
| **`database`** | PostgreSQL + PostGIS | **Docker Container (`oddi-postgres`:5432)** | **Supabase Cloud Managed PostgreSQL** |
| **`auth / storage`** | Supabase Auth / Storage | Supabase Dev Project | Supabase Prod Project (Google, Apple, Kakao) |
| **`ingress`** | NGINX Ingress Controller | Direct localhost binding | K8s Ingress (`40-ingress.yaml`, `oddi.kr`) |
| **`gitops`** | Argo CD | N/A | Argo CD Application (`argo/prod-application.yaml`) |
