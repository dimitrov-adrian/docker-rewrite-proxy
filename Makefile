tag := 'dimitrovadrian/rewrite-proxy:latest'

build:
	DOCKER_BUILDKIT=1 docker build -t $(tag) .

publish:
	docker push $(tag) .

test:
	cd test && ./test.sh

all: build publish
