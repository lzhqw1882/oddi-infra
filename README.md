# 🏗️ ODDI Infrastructure Guide & Access Directory

> **위치:** `apps/oddi-infra/README.md`  
> **관련 문서:** [[docs/01-Infrastructure-Overview]], [[docs/02-Local-Development-Setup]], [[docs/03-Kubernetes-and-Kustomize-Guide]], [[docs/04-ArgoCD-GitOps-Guide]]

---

## 🔑 1. Quick Access Guide (접속 방법 안내)

### 1.1 Argo CD 웹 콘솔 (GitOps Web UI)
- **포트포워딩 명령어:**
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```
- **접속 URL:** [https://localhost:8080](https://localhost:8080)
- **기본 계정:**
  - **아이디:** `admin`
  - **초기 비밀번호 조회 명령어:**
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    ```

---

### 1.2 로컬 PostgreSQL DB 접속 (Docker `oddi-postgres`)
- **구동 명령어:** `docker-compose up -d` (프로젝트 루트 경로)
- **접속 정보:**
  - **Host:** `localhost` (또는 `127.0.0.1`)
  - **Port:** `5432`
  - **Database:** `oddi`
  - **User:** `oddi`
  - **Password:** `oddi2026password*`
  - **DB URL:** `postgresql://oddi:oddi2026password*@localhost:5432/oddi?schema=public`

---

### 1.3 마이크로서비스 접속 (Local Development)
- **Front Web (Next.js 15):** [http://localhost:3000](http://localhost:3000)
- **Front API (NestJS):** [http://localhost:4000](http://localhost:4000)
- **Prod Web (NGINX Ingress):** `https://oddi.kr`

---

## 📂 2. 인프라 디렉토리 구조

```
apps/oddi-infra/
├── argo/                                   # Argo CD GitOps 배포 애플리케이션 CRD
│   ├── dev-application.yaml                # Dev 환경 (oddi-dev 네임스페이스)
│   └── prod-application.yaml               # Prod 환경 (oddi 네임스페이스)
├── k8s/
│   ├── base/                               # Kustomize 공통 기본 매니페스트
│   │   ├── 00-namespace.yaml               # oddi 네임스페이스
│   │   ├── 01-configmap.yaml               # 공통 환경변수
│   │   ├── 02-secret.yaml                  # 보안 데이터 (Supabase & DB Keys)
│   │   ├── 10-front-web.yaml               # Next.js 프론트엔드 (Deployment & Service)
│   │   ├── 20-front-api.yaml               # NestJS API 백엔드 (Deployment & Service)
│   │   ├── 30-oddi-batch-cronjob.yaml      # NestJS 월간 크롤링 (Kubernetes CronJob)
│   │   ├── 40-ingress.yaml                 # NGINX Ingress 라우팅 (oddi.kr)
│   │   └── kustomization.yaml
│   └── overlays/                           # 환경별 개별 설정 (dev / prod)
├── docs/                                   # 상세 인프라 명세 문서 모음
│   ├── 01-Infrastructure-Overview.md
│   ├── 02-Local-Development-Setup.md
│   ├── 03-Kubernetes-and-Kustomize-Guide.md
│   └── 04-ArgoCD-GitOps-Guide.md
└── README.md
```

---

## 🚀 3. GitOps 배포 가이드

```bash
# 1. Argo CD에 Prod 애플리케이션 등록
kubectl apply -f apps/oddi-infra/argo/prod-application.yaml

# 2. 애플리케이션 동기화(Sync) 상태 확인
argocd app get oddi-prod
```
