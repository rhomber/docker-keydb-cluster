build:
	docker build -t keydbcluster .
rebuild:
	docker build --no-cache -t keydbcluster .
down:
	docker-compose down
up:
	make down
	make build
	docker-compose up -d
monitor:
	docker-compose logs
run-cli:
	docker-compose exec keydb-cluster keydb-cli -c -p 7000
run-shell:
	docker-compose exec keydb-cluster /bin/bash
stop-swarm:
	docker stack rm keydbcluster
	docker swarm leave --force
start-swarm:
	make stop-swarm
	make build
	docker swarm init
	docker stack deploy -c docker-compose.yml keydbcluster
push:
	make build
	docker tag keydbcluster riandyrn/keydbcluster:latest
	docker push riandyrn/keydbcluster:latest
