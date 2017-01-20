#!/usr/bin/env bash

set -e

REGISTRY="net-docker-registry.adm.netways.de:5000"
IMAGE="jenkins-slave"
CONTAINER="jenkins-slave"

docker_certs="/etc/docker/certs.d"
certs_path="${docker_certs}/${REGISTRY}"
image_uri="${REGISTRY}/${IMAGE}"

if [ ! -d "$certs_path" ]; then
    mkdir -p "$certs_path"
fi

if [ ! -f "${certs_path}/ca.crt" ]; then
    echo "Storing 'Puppet CA: net-puppetmaster.adm.netways.de' in ${certs_path}/ca.crt"
    cat > "${certs_path}/ca.crt" <<EOF
CN = Puppet CA: net-puppetmaster.adm.netways.de
-----BEGIN CERTIFICATE-----
MIIFYDCCA0igAwIBAgIBATANBgkqhkiG9w0BAQsFADA1MTMwMQYDVQQDDCpQdXBw
ZXQgQ0E6IG5ldC1wdXBwZXRtYXN0ZXIuYWRtLm5ldHdheXMuZGUwHhcNMTMwNTEz
MTAxMzA1WhcNMTgwNTEzMTAxMzA1WjA1MTMwMQYDVQQDDCpQdXBwZXQgQ0E6IG5l
dC1wdXBwZXRtYXN0ZXIuYWRtLm5ldHdheXMuZGUwggIiMA0GCSqGSIb3DQEBAQUA
A4ICDwAwggIKAoICAQDN/l2iZcBERdRr5R2WLm6NavHM2fMpZMTn3IYeQVQvBclt
8S/ExsQsd8obbzss0V6eiLbN3Hodfjhb596N/npUzU4U8aq9+Rhg/PYzsUditcUM
c4sgn8wTihNc8hRZuXOVQKBZSIYPCJp1L51INLCDg6GxsopGpVaBXsC9AYme31ul
de66vjD6mzrn3ZmDAUeZlL2zI2IOmMoMv1K9W4xBSJtdOtmmPMSAoPtfPVwHTWa9
06Y9+aLJYvOyDtEKQp1hblQk4vYmwTLK5hsUaBW+9tld0NxXZXRJAF54gZVKLDkP
K15+2zHbKQn3ndjnWmuQrd8AsUc074OoXmJSSkSuQOIDduUCias7eaioQ7QwjxvL
p1ve81d0mkHWFDwlZ6OJMQ9mpytsvlA+7KFTdL1Vzmc+1gpBgBTe0T3KEY4ws6IV
EREMe5aFYuNHOCQ9Zq2w7HGmUWCGCPrf74rijtL072c/tXBns1kO6MvjGOdp+nfR
uO7LNbgMmgCw0f+WUgzDeEvkmztktrOg9v/lzVDE38UwQbzqm630V7i0i0zWecAU
JfsKRZJxjse1QwGlqJqgOlmXqLAF9vrCgJ5F3Cmp8/TmhIlYUP+jUqJ2EJC2FmD7
AVMl1vXI31bB3MMCxElOGHUVjP/SHCUEuTW0c1WZNfxHZbfh8Prhnl3xyNcuEQID
AQABo3sweTA3BglghkgBhvhCAQ0EKhYoUHVwcGV0IFJ1YnkvT3BlblNTTCBJbnRl
cm5hbCBDZXJ0aWZpY2F0ZTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB
/zAdBgNVHQ4EFgQU9TY+TX1ryBzxOPnRVJ/inUOu5SswDQYJKoZIhvcNAQELBQAD
ggIBAGuwFBbvWTSHqYx7CZq3R4Qwy2ldtJ6ById0Rz97qV2HuvS2L3C5GYkiNAzl
vO23R5Z9meEMs+4uMZdwV5gUcod5MG90rSi45ywCfcBA/MEexicF7N+6fUtHMRZX
uoVtBCTZaNC2AQ93ohkhgHe6fIeepkTMWZkDiTnCwd3N0WrtFKgkGBw3MkSyQZ43
Q7bgkxoAlXX7Xk4Yn4OAm+cDBuXjfL+DCd8pngqHmWSYU+fDdh6+KF0fQyLny9uO
8FoNNBnSNsp4Q3A29qTfkslBomsnjTRgLAPjt1561aDdpGjP+zRqi9hwD8R8pXqO
MePFpyUUOD9G4uWppkOz6wffKUFPnw/c5UemqHOhJfLlUua/No9B5/D16TPg7U/7
fudfEzABvjabX+CL/E7XUfF536W382LOPzL/0g7+w2MKnritPvcM5hiCb7tHM9ef
bP/o6s2ZCOGSMcibv61F38foCWIkc9SOEVhWqUib8YHS2S113RPNGrhqfvpUARYB
jnKGb77wDJrQknR+fQbAe7dBGPbxpZIi3Vm3iQdRNhbJRy5gXBkcMPmCuAWwwcgs
9kteJRXtu1lyEVe8jzTbdZTiQfwhMAivfsCTitQlDnAGV/89T+Vf1iirH0DXnH2a
pWXYB8xij/CdHkVl1cnh1rHtgGwi7j2oB5/IzzdVGUst46+R
-----END CERTIFICATE-----
EOF
fi

echo "Checking for an updated Docker image of ${image_uri}"
docker pull "${image_uri}"

docker_image_id() {
    docker inspect --type=image -f '{{.Id}}' "${1}"
}

docker_container_image() {
    docker inspect --type=container -f '{{.Image}}' "${1}" || true
}

docker_container_running() {
    docker inspect --type=container -f '{{.State.Running}}' "${1}" || true
}

running_id=$(docker_container_image "${CONTAINER}")
image_id=$(docker_image_id "${image_uri}")

if [ "$running_id" != "" ] && [ "$running_id" != "$image_id" ]; then
    echo "Removing outdated running container..."
    docker stop "${CONTAINER}"
    docker rm "${CONTAINER}"
fi

running=$(docker_container_running "${CONTAINER}")
if [ "$running" != "true" ]; then
    if [ "$running" = "false" ]; then
        echo "Removing stopped container..."
        docker rm "${CONTAINER}"
    fi

    echo "Starting jenkins-slave..."
    docker run -d \
        --privileged \
        -p 2222:22 \
        --restart=always \
        --name "${CONTAINER}" \
        "${image_uri}"

    echo "Injecting CA certificate into ${CONTAINER}..."
    docker exec -i "${CONTAINER}" sh -c 'mkdir -p '"$certs_path"
    docker cp "${certs_path}/ca.crt" "${CONTAINER}":"${certs_path}/ca.crt"

    # TODO: insert testing access into slave container
    echo "Setting testing jenkins password in ${CONTAINER}..."
    docker exec -i "${CONTAINER}" sh -c 'echo jenkins:jenkins | chpasswd'

    echo "Removing SSH keys from container for security..."
    docker exec -i "${CONTAINER}" rm -rf /home/jenkins/.ssh
fi
