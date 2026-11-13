# Local PostgreSQL

로컬 데이터베이스는 저장소 루트의 Docker Compose로 띄운다.

```bash
docker-compose up -d
```

- Host: `localhost`
- Port: `5432`
- Database: `oddi`
- User: `oddi`

초기 스키마와 시드는 `schema.sql`, `seed.sql`이다. 실행 절차는 `docs/02-Local-Development-Setup.md`를 본다.
