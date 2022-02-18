push: build
	docker push marcpartensky/beef
build:
	docker build . -t marcpartensky/beef
