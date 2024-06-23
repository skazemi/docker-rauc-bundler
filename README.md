# docker-rauc-bundler

Minimal docker image for creating/handling [RAUC](https://github.com/rauc/rauc) bundles

## Build

### Build default version

```bash
docker build . -t rauc-bundler:latest
```

### Build specific version

```bash
docker build . -t rauc-bundler:custom --build-arg RAUC_VERSION=v1.11.3
```

## Usage

### Get RAUC version

```bash
docker run rauc-bundler:latest --version
```

### Create bundle with host user ownership

```bash
docker run --user "$(id -u):$(id -g)" \
    -v "$(pwd)/dummy-keys":/bundle/keys \
    -v "$(pwd)/dummy-content":/bundle/input \
    -v "$(pwd)/dummy-output":/bundle/output \
    rauc-bundler:latest --keyring=keys/dummy.keyring.pem bundle \
    --cert=keys/dummy.cert.pem \
    --key=keys/dummy.key.pem \
    input/ \
    output/dummy.raucb
```

### Get bundle info

```bash
docker run \
    -v "$(pwd)/dummy-keys":/bundle/keys \
    -v "$(pwd)/dummy-output":/bundle/output \
    rauc-bundler:latest --keyring=keys/dummy.keyring.pem info \
    output/dummy.raucb
```
