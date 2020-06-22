build:
	docker-compose build uno-api

up: build
	docker-compose up -d

down:
	docker-compose down

restart:
	make down && make up

test: build
	docker-compose run uno-api bundle exec rspec

logs:
	docker-compose logs -f uno-api

bash: up
	docker-compose exec uno-api sh

