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

Tested with Airflow 2.2.4 on OpenShift 4.9.x using Helm chart 1.5.1

## Install

Add Airflow Helm repo

```
helm repo add apache-airflow https://airflow.apache.org
```

Pull Airflow Helm chart

```
helm pull apache-airflow/airflow
```

TODO: Pin version of Helm chart

Update to your version and unpack the tar file

```
tar xzf airflow-<version>.tgz
```

Copy the `airflow-values.yaml` file over the `airflow/values.yaml` file

```
cp airflow-values.yaml airflow/values.yaml
```

Copy the `charts-postgresql-values.yaml` file over the `airflow/charts/postgresql/values.yaml` file

```
cp charts-postgresql-values.yaml airflow/charts/postgresql/values.yaml
```

Change directory to the airflow folder. Install the Airflow Helm chart. Also, config values are set so the DAGs are pulled from this Git repo. 

Change repo and subPath for your deployment.

```
cd airflow
helm upgrade \
    --install airflow ./ \ 
    --namespace airflow \
    --values ./values.yaml \
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
