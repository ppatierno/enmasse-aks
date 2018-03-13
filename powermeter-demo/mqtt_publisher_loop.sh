#!/usr/bin/env bash

MQTT_ADDRESS=$1
MQTT_PORT=$2
MQTT_TOPIC=$3
MQTT_QOS=${4:-1}
MQTT_CERT=$5
COUNT=${6:-10}
SLEEP=${7:-1}

echo "Using MQTT endpoint $MQTT_ADDRESS:$MQTT_PORT"
echo "Publishing on $MQTT_TOPIC with QoS=$MQTT_QOS"
printf "\n"

for ((i=0; i<${COUNT}; i++))
do
    ./tls_mqtt_send.py -c ${MQTT_ADDRESS} -p ${MQTT_PORT} -t ${MQTT_TOPIC} -q ${MQTT_QOS} -s ${MQTT_CERT} -m "Message $i"
    printf "\n"
    sleep ${SLEEP}
done