# 🏗️ ODDI Infrastructure Guide & Access Directory

> **위치:** `apps/oddi-infra/README.md`  
> **관련 문서:** [[docs/01-Infrastructure-Overview]], [[docs/02-Local-Development-Setup]]

Kubernetes와 Argo CD는 인프라 구성요소로 사용하지 않는다. 이 저장소가 다루는 범위는 로컬 Docker PostgreSQL과 상용 Supabase다.

---

## 🔑 1. Quick Access Guide (접속 방법 안내)

### 1.1 로컬 PostgreSQL DB 접속 (Docker `oddi-postgres`)
- **구동 명령어:** `docker-compose up -d` (프로젝트 루트 경로)
- **접속 정보:**
  - **Host:** `localhost` (또는 `127.0.0.1`)
  - **Port:** `5432`
  - **Database:** `oddi`
  - **User:** `oddi`
  - **Password:** `oddi2026password*`
  - **DB URL:** `postgresql://oddi:oddi2026password*@localhost:5432/oddi?schema=public`

---

### 1.2 마이크로서비스 접속 (Local Development)
- **Front Web (Next.js 15):** [http://localhost:3000](http://localhost:3000)
- **Front API (NestJS):** [http://localhost:4000](http://localhost:4000)

---

## 📂 2. 인프라 디렉토리 구조

```
apps/oddi-infra/
├── database/                               # 스키마, 시드, 로컬 DB 메모
│   ├── schema.sql
│   ├── seed.sql
│   └── README.md
├── docker-compose.yml                      # 로컬 PostGIS 16
├── docs/                                   # 인프라 명세
│   ├── 01-Infrastructure-Overview.md
│   └── 02-Local-Development-Setup.md
└── README.md
```

`k8s/`와 `argo/`에 남아 있는 매니페스트는 배포 절차가 아니다. 클러스터 배포와 GitOps 동기화 문서는 제거했다.
