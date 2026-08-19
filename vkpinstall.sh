#!/bin/bash
# ==============================================================================
# Veeam Kubernetes Proxy (VKP) Installation on OpenShift
# ==============================================================================

# Install Helm

curl -LO https://get.helm.sh/helm-v4.2.3-linux-amd64.tar.gz
tar -zxvf helm-v4.2.3-linux-amd64.tar.gz
export PATH="$PATH:$PWD/linux-amd64"
helm version

# VKP namespace
VKP_NAMESPACE="vkp"
# VolumeSnapshotClass to be used by VKP
# Change this to the VolumeSnapshotClass used by your OpenShift storage.
VOLUMESNAPSHOTCLASS="lvms-vg1"


# ------------------------------------------------------------------------------
# Add and update Veeam VKP Helm repository
# ------------------------------------------------------------------------------

helm repo add vkp "https://staging.charts.veeam.com/"
helm repo update

# ------------------------------------------------------------------------------
# Install VKP
# ------------------------------------------------------------------------------

helm install vkp \
    vkp/vkp \
    --namespace="${VKP_NAMESPACE}" \
    --set eula.accept=true \
    --create-namespace

# ------------------------------------------------------------------------------
# Annotate the required VolumeSnapshotClass for VKP output of oc get volumesnapshotclass
# ------------------------------------------------------------------------------

oc annotate volumesnapshotclass \
    "${VOLUMESNAPSHOTCLASS}" \
    vkp.veeam.com/is-snapshot-class=true \
    --overwrite

# ------------------------------------------------------------------------------
# Display VKP OpenShift Route
# ------------------------------------------------------------------------------

oc get route -n "${VKP_NAMESPACE}"

# ------------------------------------------------------------------------------
# Display VKP Services and components
# ------------------------------------------------------------------------------

oc get all -n "${VKP_NAMESPACE}"


# ------------------------------------------------------------------------------
# Retrieve VKP service account token
# This token is used when registering VKP with Veeam Backup & Replication.
# ------------------------------------------------------------------------------

oc get secret vkp-token \
    -n "${VKP_NAMESPACE}" \
    -o jsonpath='{.data.token}' | base64 -d; echo
