#!/usr/bin/env bash

set -e

REGISTRY="net-docker-registry.adm.netways.de:5000"
IMAGE="jenkins-slave"
CONTAINER="icinga-jenkins-slave"
DATA="/data/docker/${CONTAINER}"

# WARNING: INSECURE SSH KEY
SSH_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtGIRhrYRnuzfENvBL/6YwwPIv4FVVLbHY70XpX8kUMK4oxFz9REwRK5pERNSqGOUAb66sVOLWCxgEAtfKsOxIA07OSGGzN9dlgOlNy/ud3qxbDo6RAiFHmP3eGDpA9uE0FiSMOoRqXaEG6lPFpfKta9JPOssh8rEvHQU8EAQbrYkPK8Rv6bZ3MYmTdOim1aV8HVSGmXMRtbCx/lVEpbfrnPJp/GbG1ewMXpOz9lr2YXJuhREoxcLflhlVACa7z4Ab5RxTXW71piyKV9x0X1tHb2KVbcD/byi+Sv89UwQU+ZHq3Og/57IOJcofSTWlpYlP1Fn95qrbPVzf4zVblRHR Jenkins INSECURE TEST KEY'

docker_certs="/etc/docker/certs.d"
certs_path="${docker_certs}/${REGISTRY}"
image_uri="${REGISTRY}/${IMAGE}"

###
# Update local trust for Docker registry
###
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

###
# create and provision local data directory
###
if [ ! -d "${DATA}" ]
then
    echo "Creating ${DATA}"
    mkdir -p "${DATA}"
fi

if [ ! -d "${DATA}/home" ]
then
    echo "Creating ${DATA}/home"
    mkdir "${DATA}/home"
    chown 1000.1000 "${DATA}/home"
    chmod 0700 "${DATA}/home"
fi

if [ ! -f "${DATA}/ssh/authorized_keys" ]
then
    if [ ! -d "${DATA}/ssh" ]; then
        mkdir "${DATA}/ssh"
        chown 1000.1000 "${DATA}/ssh"
        chmod 0700 "${DATA}/ssh"
    fi
    echo "Creating ${DATA}/ssh/authorized_keys"
    echo "${SSH_KEY}" > "${DATA}/ssh/authorized_keys"
    chown 1000.1000 "${DATA}/ssh/authorized_keys"
    chmod 0600 "${DATA}/ssh/authorized_keys"

elif ! grep -q "${SSH_KEY}" "${DATA}/ssh/authorized_keys"
then
    echo "Updating ${DATA}/ssh/authorized_keys"
    echo "${SSH_KEY}" > "${DATA}/ssh/authorized_keys"
    chown 1000.1000 "${DATA}/ssh/authorized_keys"
    chmod 0600 "${DATA}/ssh/authorized_keys"
fi

restart=1

###
# check if a newer image is available
###
docker_image_id() {
    docker inspect --type=image -f '{{.Id}}' "${1}"
}

image_old_id=`docker_image_id ${image_uri}` || true
echo "Checking for an updated Docker image of ${image_uri}"
docker pull "${image_uri}" >/dev/null
image_new_id=`docker_image_id ${image_uri}`

if [ "${image_old_id}" != "${image_new_id}" ]
then
    echo "Image ${image_uri} has been updated, scheduling restart..."
    restart=0
fi

###
# check if systemd is up to date
###
systemd_unit="docker-${CONTAINER}.service"
systemd_unit_file="/etc/systemd/system/${systemd_unit}"
systemd_unit_file_tmp=`mktemp systemd.XXXXXX`
trap "rm -f ${systemd_unit_file_tmp}" EXIT SIGINT

cat > "${systemd_unit_file_tmp}" <<EOF
[Unit]
Description=Icinga Jenkins slave in Docker
After=docker.service
Requires=docker.service

[Service]
Restart=always
StartLimitInterval=20
StartLimitBurst=5
TimeoutStartSec=0
SyslogIdentifier=docker-${CONTAINER}
ExecStartPre=-/usr/bin/docker kill "${CONTAINER}"
ExecStartPre=-/usr/bin/docker rm  "${CONTAINER}"

ExecStart=/usr/bin/docker run \\
        --privileged \\
        -p 2222:22 \\
        -e "DOCKER_DAEMON_ARGS=--storage-driver overlay" \\
        -v /etc/docker/certs.d:/etc/docker/certs.d:ro \\
        -v "${DATA}/home":/home/jenkins \\
        -v "${DATA}/ssh":/home/jenkins/.ssh:ro \\
        -v "${DATA}/docker":/var/lib/docker \\
        --restart=always \\
        --name "${CONTAINER}" \\
        "${image_uri}"

ExecStop=-/usr/bin/docker stop --time=0 ${CONTAINER}
ExecStop=-/usr/bin/docker rm  ${CONTAINER}

[Install]
WantedBy=multi-user.target
EOF

if [ ! -f "${systemd_unit_file}" ]
then
    echo "Creating ${systemd_unit_file}..."
    cp "${systemd_unit_file_tmp}" "${systemd_unit_file}"

    echo "Reloading systemd..."
    systemctl daemon-reload
    restart=0

elif ! cmp --silent "${systemd_unit_file}" "${systemd_unit_file_tmp}"
then
    echo "Replacing ${systemd_unit_file} with new version..."
    diff -u "${systemd_unit_file}" "${systemd_unit_file_tmp}" || true
    cp "${systemd_unit_file_tmp}" "${systemd_unit_file}"

    echo "Reloading systemd..."
    systemctl daemon-reload
    restart=0
fi

if ! systemctl is-enabled ${systemd_unit} >/dev/null
then
    echo "Enabling service ${systemd_unit} for autostart"
    systemctl enable ${systemd_unit}
fi

if [ ${restart} -eq 0 ]
then
    echo "Restarting service ${systemd_unit}"
    systemctl restart ${systemd_unit}

elif ! systemctl is-active ${systemd_unit} >/dev/null
then
    echo "Starting service ${systemd_unit}"
    systemctl start ${systemd_unit}

else
    echo "Service ${systemd_unit} is running."
fi
