tag="dimitrovadrian/rewrite-proxy:${1:-latest}"
export DOCKER_BUILDKIT=1
docker build --compress -t "$tag" . \
    && docker push "$tag"
