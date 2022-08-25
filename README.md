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

### Install Airflow via Helm

```
# add helm repo
helm repo add apache-airflow https://airflow.apache.org

# get project
PROJECT=$(oc project -q)

# get openshift uid/gid range
CHART_UID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.uid-range']}" | sed "s@/.*@@")
CHART_GID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.supplemental-groups']}" | sed "s@/.*@@")

echo "UID/GID: $CHART_UID/$CHART_GID"

# install via helm
helm upgrade \
    --install airflow apache-airflow/airflow \
    --namespace airflow \
    --set uid=$CHART_UID \
    --set gid=$CHART_GID \
    --set statsd.securityContext.runAsUser=$CHART_UID \
    --set redis.securityContext.runAsUser=$CHART_UID \
    --set postgresql.securityContext.enabled=false \
    --set postgresql.containerSecurityContext.enabled=false \
    --set dags.gitSync.repo=https://github.com/redhat-na-ssa/airflow-on-openshift.git \
    --set dags.gitSync.branch=main \
    --set dags.gitSync.subPath=example_dag
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
    --namespace airflow \
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

## Development

TODO

## References

TODO
