# ☸️ Kubernetes & Kustomize Deployment Guide

> **위치:** `apps/oddi-infra/docs/03-Kubernetes-and-Kustomize-Guide.md`  
> **최종 수정일:** 2026-08-02  
> **관련 문서:** [[01-Infrastructure-Overview]], [[04-ArgoCD-GitOps-Guide]]

---

## 1. 개요

본 문서는 상용(Production) 및 개발(Dev) 클러스터 배포를 위해 **Kustomize** 패턴으로 구성된 Kubernetes 매니페스트 구조와 각 마이크로서비스 리소스 명세를 설명합니다.

---

## 2. K8s 디렉토리 매니페스트 구조

```
apps/oddi-infra/k8s/
├── base/                              # 공통 기본 리소스
│   ├── 00-namespace.yaml              # oddi 네임스페이스
│   ├── 01-configmap.yaml              # 공통 환경변수 (NODE_ENV, SUPABASE_URL 등)
│   ├── 02-secret.yaml                 # 보안 데이터 (SUPABASE_KEY, DATABASE_URL 등)
│   ├── 10-front-web.yaml               # Next.js 프론트엔드 (Deployment & Service)
│   ├── 20-front-api.yaml               # NestJS API 백엔드 (Deployment & Service)
│   ├── 30-oddi-batch-cronjob.yaml      # NestJS 월간 크롤링 (CronJob)
│   ├── 40-ingress.yaml                # NGINX Ingress 라우터 (oddi.kr)
│   └── kustomization.yaml              # Base 매니페스트 묶음
└── overlays/                           # 환경별 차이점 재정의
    ├── dev/                           # 개발 환경 (kustomization.yaml)
    └── prod/                          # 운영 환경 (kustomization.yaml)
```

---

## 3. 매니페스트별 역할 및 주요 설정

### 3.1 `10-front-web.yaml` (Next.js Frontend)
- **Replicas:** 2
- **Port:** 3000
- **Resource Limits:** CPU 500m, Memory 512Mi

### 3.2 `20-front-api.yaml` (NestJS Backend API)
- **Replicas:** 2
- **Port:** 4000
- **Resource Limits:** CPU 500m, Memory 512Mi

### 3.3 `30-oddi-batch-cronjob.yaml` (Monthly Crawler CronJob)
- **Schedule:** `0 0 1 * *` (매월 1일 자정 00:00 자동 발동)
- **ConcurrencyPolicy:** `Forbid` (중복 실행 방지)
- **Resource Limits:** CPU 1000m, Memory 1Gi

### 3.4 `40-ingress.yaml` (NGINX Ingress Routing)
- Host: `oddi.kr`
- `/api` $\rightarrow$ `front-api-service:80`
- `/` $\rightarrow$ `front-web-service:80`

---

## 4. 수동 배포 명령어 (Manual Apply)

Argo CD 자동 배포 외에 CLI로 수동 배포 및 테스트 시:

```bash
# 1. Dev 환경 배포 테스트
kubectl apply -k apps/oddi-infra/k8s/overlays/dev

# 2. Prod 환경 배포 테스트
kubectl apply -k apps/oddi-infra/k8s/overlays/prod

# 3. 배포된 Pods 및 CronJob 상태 확인
kubectl get pods -n oddi
kubectl get cronjob -n oddi
```
