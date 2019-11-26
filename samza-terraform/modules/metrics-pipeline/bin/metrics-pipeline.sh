#!/bin/sh

SERVICE_WAIT_TIMEOUT_SEC=300

METRICS_COLLECTOR_TARBALL="samza-metrics-collector-release-linux-0.0.2.tar.gz"
METRICS_COLLECTOR_TARBALL_URI="https://github.com/dnishimura/samza-metrics-collector/releases/download/0.0.2/$METRICS_COLLECTOR_TARBALL"
METRICS_COLLECTOR_DIR="samza-metrics-collector-release"
METRICS_COLLECTOR_PID_FILE="samza-metrics-collector.pid"

PROMETHEUS_TARBALL="prometheus-2.14.0.linux-amd64.tar.gz"
PROMETHEUS_TARBALL_URI="https://github.com/prometheus/prometheus/releases/download/v2.14.0/$PROMETHEUS_TARBALL"

BASE_DIR="$(pwd)"
DEPLOY_ROOT_DIR="${BASE_DIR}/deploy"
LOG_DIR="${BASE_DIR}/logs"
mkdir -p $LOG_DIR

DOWNLOAD_CACHE_DIR="${BASE_DIR}/.download"
mkdir -p "${DOWNLOAD_CACHE_DIR}"

KAFKA_SERVER=$(head -n 1 kafka-server.conf)
KAFKA_IP=$(awk -F: '{print $1}' <<< $KAFKA_SERVER)
KAFKA_PORT=$(awk -F: '{print $2}' <<< $KAFKA_SERVER)

download() {
  pushd $DOWNLOAD_CACHE_DIR
  wget $METRICS_COLLECTOR_TARBALL_URI
  tar -zxf $METRICS_COLLECTOR_TARBALL -C $BASE_DIR
  wget $PROMETHEUS_TARBALL_URI
  tar -zxf $PROMETHEUS_TARBALL -C $BASE_DIR
  popd
}

wait_for_kafka() {
  echo "Waiting for Kafka to start on $KAFKA_IP $KAFKA_PORT..."
  local CURRENT_WAIT_TIME=0

  while [ $(echo | nc -w1 $KAFKA_IP $KAFKA_PORT >/dev/null 2>&1 ;echo $?) -ne 0 ]; do
      printf '.'
      sleep 1
      if [ $((++CURRENT_WAIT_TIME)) -eq $SERVICE_WAIT_TIMEOUT_SEC ]; then
        printf "\nError: timed out while waiting for Kafka to start.\n"
        exit 1
      fi
  done
  printf '\n'
  echo "Kafka has started";
}

install_java() {
  sudo apt install -y openjdk-8-jre-headless
}

setup_java() {
  export JAVA_HOME=`readlink -f /usr/bin/java | sed "s:/bin/java::"`
}

start_metrics() {
  pushd $BASE_DIR
  wait_for_kafka
  echo "Starting samza-metrics-collector connecting to Kafka server at $KAFKA_SERVER"
  LD_LIBRARY_PATH=$METRICS_COLLECTOR_DIR nohup $METRICS_COLLECTOR_DIR/samza-metrics-collector -kafka.bootstrap.servers=$KAFKA_SERVER > $LOG_DIR/samza-metrics-collector.log 2>&1 & echo $! > $METRICS_COLLECTOR_PID_FILE
  sleep 1
  PROMETHEUS_DIR=$(ls | grep prometheus)
  
  popd
}

stop_metrics() {
  pushd $BASE_DIR
  COLLECTOR_PID=`head -n 1 $METRICS_COLLECTOR_PID_FILE`
  kill -9 $COLLECTOR_PID
}

case $1 in
  start)
    download
    start_metrics
    exit 0
  ;;

  stop)
    stop_metrics
    exit 0
  ;;
esac

echo "Usage: $0 stop|start"
