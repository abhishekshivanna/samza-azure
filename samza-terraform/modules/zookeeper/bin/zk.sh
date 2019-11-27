#!/bin/sh

ZOOKEEPER_TARBALL="https://archive.apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz"
ZOOKEEPER_PORT=2181
SERVICE_NAME="zookeeper"
SERVICE_WAIT_TIMEOUT_SEC=20


BASE_DIR="$(pwd)"
DEPLOY_ROOT_DIR="${BASE_DIR}/deploy"

DOWNLOAD_CACHE_DIR="${BASE_DIR}/.download"
mkdir -p "${DOWNLOAD_CACHE_DIR}"

download() {
  PACKAGE_FILE_NAME="${DOWNLOAD_CACHE_DIR}/${SERVICE_NAME}"
  if [ -f "${PACKAGE_FILE_NAME}.tar.gz" ]; then
    echo "Using previously downloaded file ${PACKAGE_FILE_NAME}"
  else
    echo "Downloading ${ZOOKEEPER_TARBALL}"
    curl "${ZOOKEEPER_TARBALL}" > "${PACKAGE_FILE_NAME}.tmp"
    mv "${PACKAGE_FILE_NAME}.tmp" "${PACKAGE_FILE_NAME}.tar.gz"
  fi
  rm -rf "${DEPLOY_ROOT_DIR}"
  mkdir -p "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}"
  tar -xf "${PACKAGE_FILE_NAME}.tar.gz" --strip-components=1 -C "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}"
}

wait_for_service() {
  echo "Waiting for $SERVICE_NAME to start..."
  local CURRENT_WAIT_TIME=0

  while [ $(echo | nc -w1 localhost $ZOOKEEPER_PORT >/dev/null 2>&1 ;echo $?) -ne 0 ]; do
      printf '.'
      sleep 1
      if [ $((++CURRENT_WAIT_TIME)) -eq $SERVICE_WAIT_TIMEOUT_SEC ]; then
        printf "\nError: timed out while waiting for $SERVICE_NAME to start.\n"
        exit 1
      fi
  done
  printf '\n'
  echo "$SERVICE_NAME has started";
}

install_java() {
  sudo apt install -y openjdk-8-jre-headless
}

setup_java() {
  export JAVA_HOME=`readlink -f /usr/bin/java | sed "s:/jre/bin/java::"`
}

install_zookeeper() {
  download
  cp "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}/conf/zoo_sample.cfg" "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}/conf/zoo.cfg"
}

start_zookeeper() {
  setup_java
  if [ -f "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}/bin/zkServer.sh" ]; then
    cd "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}"
    bin/zkServer.sh start
    wait_for_service
    cd - > /dev/null
  else
    echo 'ERROR: Zookeeper is not installed at: ${DEPLOY_ROOT_DIR}/${SERVICE_NAME}'
  fi
}

stop_zookeeper() {
  setup_java
  if [ -f "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}/bin/zkServer.sh" ]; then
    cd "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}"
    bin/zkServer.sh stop
    cd - > /dev/null
  else
    echo 'ERROR: Zookeeper is not installed at: ${DEPLOY_ROOT_DIR}/${SERVICE_NAME}'
  fi
}

case $1 in
  start)
    install_zookeeper
    start_zookeeper
    exit 0
  ;;

  stop)
    stop_zookeeper
    exit 0
  ;;
esac

echo "Usage: $0 stop|start"