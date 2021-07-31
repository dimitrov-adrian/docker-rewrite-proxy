export DOCKER_BUILDKIT=1
tag="dimitrovadrian/rewrite-proxy:${1:-latest}"
docker build --compress -t "$tag" . && docker push "$tag"
