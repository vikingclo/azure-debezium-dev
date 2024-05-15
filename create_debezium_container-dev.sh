#!/bin/bash

#export ACI_STORAGE_ACCOUNT='s'
#export ACI_STORAGE_FILESHARE='fsdebezium'
#export ACI_STORAGE_KEY=''
#export ACI_STORAGE_DIR='/dir1/'
export ACI_RESOURCE_GROUP="RG-LAX-DataSolutions-Dev-DataStreaming"
export ACI_NAME="debezium-stream-docker-evolution-dev"
export EH_PUBLIC_HOSTNAME=""
export EH_CONNECTION_STRING=""

#--azure-file-volume-account-name ${ACI_STORAGE_ACCOUNT} \
#--azure-file-volume-share-name ${ACI_STORAGE_FILESHARE} \
#--azure-file-volume-account-key ${ACI_STORAGE_KEY} \
#--azure-file-volume-mount-path ${ACI_STORAGE_DIR} \

echo "Running az container create..."
MSYS_NO_PATHCONV=1 az account set --subscription "LAX Data Solutions Dev"
MSYS_NO_PATHCONV=1 az container create -g ${ACI_RESOURCE_GROUP} -n ${ACI_NAME} \
	--image debezium/connect:1.9 \
	--ports 8083 --ip-address Private \
	--vnet "" \
	--subnet "" \
	--os-type Linux --cpu 2 --memory 16 \
	--location westus2 \
	--restart-policy OnFailure \
	--environment-variables \
		BOOTSTRAP_SERVERS=${EH_PUBLIC_HOSTNAME}:9093 \
		GROUP_ID=1 \
		CONFIG_STORAGE_TOPIC=debezium_configs \
		OFFSET_STORAGE_TOPIC=debezium_offsets \
		STATUS_STORAGE_TOPIC=debezium_statuses \
		CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE=false \
		CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE=true \
		CONNECT_REQUEST_TIMEOUT_MS=60000 \
		CONNECT_SECURITY_PROTOCOL=SASL_SSL \
		CONNECT_SASL_MECHANISM=PLAIN \
		CONNECT_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username=\"\$ConnectionString\" password=\"${EH_CONNECTION_STRING}\";" \
		CONNECT_PRODUCER_SECURITY_PROTOCOL=SASL_SSL \
		CONNECT_PRODUCER_SASL_MECHANISM=PLAIN \
		CONNECT_PRODUCER_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username=\"\$ConnectionString\" password=\"${EH_CONNECTION_STRING}\";" \
		CONNECT_CONSUMER_SECURITY_PROTOCOL=SASL_SSL \
		CONNECT_CONSUMER_SASL_MECHANISM=PLAIN \
		CONNECT_CONSUMER_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username=\"\$ConnectionString\" password=\"${EH_CONNECTION_STRING}\";"

echo "Done"

exec $SHELL