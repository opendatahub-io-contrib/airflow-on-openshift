# Airflow on OpenShift

Deploy Airflow on OpenShift via Helm

## Table of Contents

* [Requirements](#requirements)
* [Install](#install)
* [Usage](#usage)
* [Tests](#tests)
* [References](#references)

## Requirements

* OpenShift cluster with a project / namespace
* [oc](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable) - OpenShift CLI
* [helm](https://helm.sh/docs/intro/install)

### Compatability

Tested with:
* Airflow 2.2.4
* OpenShift 4.9.x
* Helm chart 1.5.1

## Install

Use `helm` to download charts

```
helm repo add apache-airflow https://airflow.apache.org
```
TODO: Pin version of Helm chart

```
CHART_UID=$(oc get project airflow -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.uid-range']}" | sed "s@/.*@@")
CHART_GID=$(oc get project airflow -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.supplemental-groups']}" | sed "s@/.*@@")

helm upgrade \
    --install airflow apache-airflow/airflow \
    --namespace airflow \
    --values ./values.yaml \
    --set uid=$CHART_UID \
    --set gid=$CHART_GID \
    --set statsd.securityContext.runAsUser=$CHART_UID \
    --set redis.securityContext.runAsUser=$CHART_UID \
    --set dags.gitSync.repo=https://github.com/redhat-na-ssa/airflow-on-openshift.git \
    --set dags.gitSync.branch=main \
    --set dags.gitSync.subPath=example_dag
```

Create route for Airflow web UI

```
oc create route edge \
    --service=airflow-webserver \
    --insecure-policy=Redirect \
    --port=8080
```

Create route for the Airflow Flower web UI

```
oc create route edge \
    --service=airflow-flower \
    --insecure-policy=Redirect \
    --port=5555
```

Confirm routes

```
oc get routes
```

## Usage

TODO

### Tests

TODO

## References

Steps originate from https://dsri.maastrichtuniversity.nl/docs/workflows-airflow/
