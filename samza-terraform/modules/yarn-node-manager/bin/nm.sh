#!/bin/sh

YARN_TARBALL="https://archive.apache.org/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz"
SERVICE_NAME="node-manager"
NODEMANAGER_PORT=8042
SERVICE_WAIT_TIMEOUT_SEC=20

BASE_DIR="$(pwd)"
DEPLOY_ROOT_DIR="${BASE_DIR}/deploy"

DOWNLOAD_CACHE_DIR="${BASE_DIR}/.download"
mkdir -p "${DOWNLOAD_CACHE_DIR}"

download() {
  PACKAGE_FILE_NAME="${DOWNLOAD_CACHE_DIR}/yarn"
  if [ -f "${PACKAGE_FILE_NAME}.tar.gz" ]; then
    echo "Using previously downloaded file ${PACKAGE_FILE_NAME}"
  else
    echo "Downloading ${YARN_TARBALL}"
    curl "${YARN_TARBALL}" > "${PACKAGE_FILE_NAME}.tmp"
    mv "${PACKAGE_FILE_NAME}.tmp" "${PACKAGE_FILE_NAME}.tar.gz"
  fi
  rm -rf "${DEPLOY_ROOT_DIR}"
  mkdir -p "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}"
  tar -xf "${PACKAGE_FILE_NAME}.tar.gz" --strip-components=1 -C "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}"
}

wait_for_service() {
  echo "Waiting for ${SERVICE_NAME} to start..."
  local CURRENT_WAIT_TIME=0

  while [ $(echo | nc -w1 localhost $NODEMANAGER_PORT >/dev/null 2>&1 ;echo $?) -ne 0 ]; do
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
  export JAVA_HOME="$(dirname $(dirname -- $(dirname -- $(readlink -f $(which java)))))"
}

install_node_manager() {
  download
  install_java
  cp "${BASE_DIR}/yarn-site.xml" "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}/etc/hadoop/yarn-site.xml"
}

start_node_manager() {
  setup_java
  if [ -f "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}/sbin/yarn-daemon.sh" ]; then
    $DEPLOY_ROOT_DIR/$SERVICE_NAME/sbin/yarn-daemon.sh start nodemanager
    wait_for_service "nodemanager" $NODEMANAGER_PORT
  else
    echo 'ERROR: Node Manager is not installed'
  fi
}

stop_node_manager() {
  setup_java
  if [ -f "${DEPLOY_ROOT_DIR}/${SERVICE_NAME}/sbin/yarn-daemon.sh" ]; then
    $DEPLOY_ROOT_DIR/$SERVICE_NAME/sbin/yarn-daemon.sh stop nodemanager
  else
    echo 'ERROR: Node Manager is not installed'
  fi
}

case $1 in
  start)
    install_node_manager
    start_node_manager
    exit 0
  ;;

  stop)
    stop_node_manager
    exit 0
  ;;
esac

echo "Usage: $0 stop|start"