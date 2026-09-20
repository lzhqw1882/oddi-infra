# 포트포워딩 백그라운드로 실행 
kubectl port-forward service/oddi-dev-db-postgresql-service 5432:5432 -n oddi-dev &