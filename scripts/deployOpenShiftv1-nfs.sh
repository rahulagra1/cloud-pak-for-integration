#!/bin/bash

echo $(date) " - ############## Starting Script ####################"

set -e

export SUDOUSER=$1
export OPENSHIFTPASSWORD=$2
export SSHKEY=$3
export WORKERCOUNT=$4
export MASTERCOUNT=$5
export SUBSCRIPTIONID=$6
export TENANTID=$7
export AADCLIENTID=$8
export AADSECRET=$9
export RESOURCEGROUPNAME=${10}
export LOCATION=${11}
export VIRTUALNETWORKNAME=${12}
export PXSPECURL=${13}
export STORAGEOPTION=${14}
export NFSIPADDRESS=${15}
export SINGLEORMULTI=${16}
export ARTIFACTSLOCATION=${17}
export ARTIFACTSTOKEN=${18}
export BASEDOMAIN=${19}
export MASTERINSTANCETYPE=${20}
export WORKERINSTANCETYPE=${21}
export CLUSTERNAME=${22}
export CLUSTERNETWORKCIDR=${23}
export HOSTADDRESSPREFIX=${24}
export VIRTUALNETWORKCIDR=${25}
export SERVICENETWORKCIDR=${26}
export BASEDOMAINRG=${27}
export NETWORKRG=${28}
export MASTERSUBNETNAME=${29}
export WORKERSUBNETNAME=${30}
export PULLSECRET=${31}
export FIPS=${32}
export PUBLISH=${33}
export OPENSHIFTUSER=${34}
export OPENSHIFTVERSION=${35}


#Var
export INSTALLERHOME=/home/$SUDOUSER/.openshift


runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/machine-health-check.yaml"
echo $(date) " - Machine Health Check setup complete"

echo $(date) " - Setting up $STORAGEOPTION"
if [[ $STORAGEOPTION == "portworx" ]]; then
  runuser -l $SUDOUSER -c "wget $ARTIFACTSLOCATION/scripts/px-install.yaml$ARTIFACTSTOKEN -O $INSTALLERHOME/openshiftfourx/px-install.yaml"
  runuser -l $SUDOUSER -c "wget $ARTIFACTSLOCATION/scripts/px-storageclasses.yaml$ARTIFACTSTOKEN -O $INSTALLERHOME/openshiftfourx/px-storageclasses.yaml"
  runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/px-install.yaml"
  runuser -l $SUDOUSER -c "sleep 30"
  runuser -l $SUDOUSER -c "oc apply -f '$PXSPECURL'"
  runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/px-storageclasses.yaml"
fi

if [[ $STORAGEOPTION == "nfs" ]]; then
  runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:kube-system:nfs-client-provisioner"
  runuser -l $SUDOUSER -c "wget $ARTIFACTSLOCATION/scripts/nfs-template.yaml$ARTIFACTSTOKEN -O  /home/azureuser/.openshift/openshiftfourx/nfs-template.yaml"
  runuser -l $SUDOUSER -c "oc process -f /home/azureuser/.openshift/openshiftfourx/nfs-template.yaml -p NFS_SERVER=$NFSIPADDRESS -p NFS_PATH=/exports/home | oc create -n kube-system -f -"
fi
echo $(date) " - Setting up $STORAGEOPTION - Done"