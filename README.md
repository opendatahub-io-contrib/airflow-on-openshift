# Airflow on OpenShift

Deploy Airflow on OpenShift via Helm

## Table of Contents

* [Requirements](#requirements)
* [Install](#install)
* [Development](#development)
* [References](#references)

## Requirements

* OpenShift cluster with a project / namespace
* [oc](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable) - OpenShift CLI
* [helm](https://helm.sh/docs/intro/install)

### Compatability

Tested with:

* Airflow 2.3.0
* OpenShift 4.10.x
* Helm chart 1.6.0

## Install

### Quickstart

```
hacks/easy_install.sh
```

### Install Airflow via `--set`

```
# add helm repo
helm repo add apache-airflow https://airflow.apache.org

# get project
PROJECT=$(oc project -q)

# get openshift uid/gid range
CHART_UID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.uid-range']}" | sed "s@/.*@@")
CHART_GID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.supplemental-groups']}" | sed "s@/.*@@")

echo "UID/GID: ${CHART_UID}/${CHART_GID}"

# install via helm
helm upgrade \
    --install airflow apache-airflow/airflow \
    --namespace ${PROJECT} \
    --set uid=${CHART_UID} \
    --set gid=${CHART_GID} \
    --set redis.securityContext.runAsUser=${CHART_UID} \
    --set postgresql.primary.podSecurityContext.enabled=false \
    --set postgresql.primary.containerSecurityContext.enabled=false \
    --set airflow.dags.gitSync.enabled=true \
    --set airflow.dags.gitSync.repo=https://github.com/opendatahub-io-contrib/airflow-on-openshift.git \
    --set airflow.dags.gitSync.branch=main \
    --set airflow.dags.gitSync.subPath=dags
```

### Install via `values.yaml` (alternative)

Note: You do not need to do this if you used the method above.

```
# copy and edit values.yaml
cp example_values.yaml values.yaml
# vim values.yaml

# install via helm
helm upgrade \
    --install airflow apache-airflow/airflow \
    --namespace ${PROJECT} \
    --set uid=${CHART_UID} \
    --set gid=${CHART_GID} \
    --set redis.securityContext.runAsUser=${CHART_UID} \
    --values ./values.yaml

# kludges

# triggerer
oc patch statefulset/airflow-triggerer --patch '{"spec":{"template":{"spec":{"initContainers":[{"name":"git-sync-init","securityContext":null}]}}}}'

oc patch statefulset/airflow-triggerer --patch '{"spec":{"template":{"spec":{"containers":[{"name":"git-sync","securityContext":null}]}}}}'

# worker
oc patch statefulset/airflow-worker --patch '{"spec":{"template":{"spec":{"initContainers":[{"name":"git-sync-init","securityContext":null}]}}}}'

oc patch statefulset/airflow-worker --patch '{"spec":{"template":{"spec":{"containers":[{"name":"git-sync","securityContext":null}]}}}}'
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

## Development

TODO:
* Improve Example Values
  * Create 3 example `values.yaml` for common use cases
    * Use K8S executor
    * TBD

## References

* [Airflow - Helm charts](https://airflow.apache.org/docs/helm-chart/stable/parameters-ref.html)
* [Airflow - Community Helm charts](https://github.com/airflow-helm/charts)
* [Airflow - Helm example values](https://github.com/airflow-helm/charts/blob/main/charts/airflow/sample-values-KubernetesExecutor.yaml)
