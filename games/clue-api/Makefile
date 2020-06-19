build:
	docker-compose build clue-api

up: build
	docker-compose up -d

down:
	docker-compose down

restart:
	make down && make up

test: build
	docker-compose run clue-api bundle exec rspec

logs:
	docker-compose logs -f clue-api

bash: up
	docker-compose exec clue-api sh

