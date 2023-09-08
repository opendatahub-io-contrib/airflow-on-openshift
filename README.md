# Airflow on OpenShift

Deploy Airflow on OpenShift via Helm

## Table of Contents

* [Requirements](#requirements)
* [Install](#install)
* [References](#references)

## Requirements

* OpenShift cluster with a project / namespace
* [oc](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable) - OpenShift CLI
* [helm](https://helm.sh/docs/intro/install)

### Compatibility

Tested with:

* Airflow 2.6.2 - 2.7.0
* OpenShift 4.11+
* Helm chart 1.10.0

## Install

### Quickstart

```
scripts/easy_install.sh
```

### Install Airflow via `helm`

```
# add helm repo
helm repo add apache-airflow https://airflow.apache.org

# get project
PROJECT=$(oc project -q)

# get openshift uid/gid range
CHART_UID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.uid-range']}" | sed "s@/.*@@")
CHART_GID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.supplemental-groups']}" | sed "s@/.*@@")

echo "UID/GID: ${CHART_UID}/${CHART_GID}"

# copy and edit values.yaml
cp example_values.yaml values.yaml

# edit values.yaml

# install via helm
helm upgrade \
    --install airflow apache-airflow/airflow \
    --namespace ${PROJECT} \
    --version 1.10.0 \
    --set uid=${CHART_UID} \
    --set gid=${CHART_GID} \
    --set redis.securityContext.runAsUser=${CHART_UID} \
    --values ./values.yaml
```

### Create Routes

```
# create route for airflow
oc create route edge \
    --service=airflow-webserver \
    --insecure-policy=Redirect \
    --port=8080

# create route for airflow flower
oc create route edge \
    --service=airflow-flower \
    --insecure-policy=Redirect \
    --port=5555

# confirm routes
oc get routes
```

## References

* [Airflow - Helm charts](https://airflow.apache.org/docs/helm-chart/stable/parameters-ref.html)
* [Airflow - Community Helm charts](https://github.com/airflow-helm/charts)
* [Airflow - Helm example values](https://github.com/airflow-helm/charts/blob/main/charts/airflow/sample-values-KubernetesExecutor.yaml)
* [Airflow - DAG Examples](https://github.com/apache/airflow.git)
