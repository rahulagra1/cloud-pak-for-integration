#!/bin/bash

export cluster_name=$1
export domain_name=$2
export openshift_user=$3
export openshift_password=$4
export namespace=$5

release_name="apic"
echo "Release Name:" ${release_name}

echo "Logging to Openshift - https://api.${cluster_name}.${domain_name}:6443 .."
var=0
oc login "https://api.${cluster_name}.${domain_name}:6443" -u "$openshift_user" -p "$openshift_password" --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"

echo "Installing API Connect in ${namespace} .."
echo "Tracing is currently set to false"

cat << EOF | oc apply -f -
apiVersion: apiconnect.ibm.com/v1beta1
kind: APIConnectCluster
metadata:
  labels:
    app.kubernetes.io/instance: apiconnect
    app.kubernetes.io/managed-by: ibm-apiconnect
    app.kubernetes.io/name: apiconnect-${namespace}
  name: ${release_name}
  namespace: ${namespace}
spec:
  license:
    accept: true
    use: nonproduction
  profile: n3xc4.m16
  version: 10.0.1.0
  gateway:
    apicGatewayServiceV5CompatibilityMode: true
EOF

echo "Validating API Connect installation.."
apic=0
time=0
while [[ apic -eq 0 ]]; do

	if [ $time -gt 5 ]; then
      		echo "Timed-out : API Connect Installation failed.."
      		exit 1
    	fi
	
	oc get pods -n ${namespace} | grep ${release_name} | grep Running | grep gw
	resp=$?
	if [[ resp -ne 0 ]]; then
		echo -e "No running pods found for ${release_name} Waiting.."
		time=$((time + 1))
		sleep 60
	else
    echo "API Connect Installation successful.."
		apic=1;
	fi
	
done
