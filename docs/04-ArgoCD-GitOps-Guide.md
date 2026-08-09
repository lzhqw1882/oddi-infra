# 🐙 Argo CD GitOps Deployment Guide

> **위치:** `apps/oddi-infra/docs/04-ArgoCD-GitOps-Guide.md`  
> **최종 수정일:** 2026-08-02  
> **관련 문서:** [[01-Infrastructure-Overview]], [[03-Kubernetes-and-Kustomize-Guide]]

---

## 1. 개요

오디(ODDI) 인프라는 **Argo CD**를 활용한 **GitOps(Git 기반 지속적 배포)** 방식으로 구축되어 있습니다. Git 리포지토리의 `apps/oddi-infra/k8s/overlays/prod` 변경 사항이 감지되면 Argo CD가 Kubernetes 클러스터에 배포 상태를 **자동 동기화(Automated Sync, Self-Healing, Pruning)**합니다.

---

## 2. Argo CD Application 명세

### 2.1 Production Application (`apps/oddi-infra/argo/prod-application.yaml`)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: oddi-prod
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: 'https://github.com/your-user/oddi.git'
    targetRevision: HEAD
    path: apps/oddi-infra/k8s/overlays/prod
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: oddi
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

---

## 3. Argo CD 등록 및 운용 방법

### 3.1 Argo CD CLI로 애플리케이션 등록
```bash
# Argo CD 클러스터에 Prod 애플리케이션 등록
kubectl apply -f apps/oddi-infra/argo/prod-application.yaml

# (선택) Dev 애플리케이션 등록
kubectl apply -f apps/oddi-infra/argo/dev-application.yaml
```

### 3.2 배포 상태 점검 및 동기화 (Sync)
```bash
# 동기화 상태 확인
argocd app get oddi-prod

# 수동 강제 동기화 트리거
argocd app sync oddi-prod
```
