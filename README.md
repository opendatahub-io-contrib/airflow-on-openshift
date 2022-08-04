# Airflow on OpenShift

Deploy Airflow on OpenShift

## Table of Contents

* [Requirements](#requirements)
* [General and Open Data Hub Information](#general-and-open-data-hub-information)
* [Install](#install)
* [Usage](#usage)
  * [Tests (TODO)](#tests)
* [References](#references)

## Requirements

1. OpenShift cluster with admin permissions
2. OpenShift CLI, the `oc` command
3. [Helm](https://helm.sh/)

## General and Open Data Hub Information

**Repository Description:**

Instructions and tools for deploying and using the Airflow on Kubernetes using the Helm package manager on OpenShift alongside Open Data Hub.

**Compatability:**

* Tested with Airflow 2.2.4 onOpenShift 4.9 using Helm chart 1.5.1
* No link with Open Data Hub, so will work with any version

## Install

1. Login to OpenShift cluster as cluster admin

    ```bash
    oc login <token>
    ```

2. Create a project using the `create-project.yml` file (Required)

    ```bash
    oc create -f create-project.yaml
    ```

3. Change to `airflow` project

    ```bash
    oc project airflow
    ```

4. Add Airflow Helm repo

    ```bash
    helm repo add apache-airflow https://airflow.apache.org
    ```

5. Pull Airflow Helm chart

    ```bash
    helm pull apache-airflow/airflow
    ```

    TODO pin version of Helm chart

6. Update to your version and unpack the tar file

    ```bash
    tar xzf airflow-<version>.tgz
    ```

7. Copy the `airflow-values.yaml` file over the `airflow/values.yaml` file

    ```bash
    cp airflow-values.yaml airflow/values.yaml
    ```

8. Copy the `charts-postgresql-values.yaml` file over the `airflow/charts/postgresql/values.yaml` file

    ```bash
    cp charts-postgresql-values.yaml airflow/charts/postgresql/values.yaml
    ```

9. Change directory to the airflow folder. Install the Airflow Helm chart. Also, config values are set so the DAGs are pulled from this Git repo. Change repo and subPath for your deployment.

    ```bash
    cd airflow && helm upgrade --install airflow ./ --namespace airflow \
    --values ./values.yaml \
    --set dags.gitSync.repo=https://github.com/redhat-na-ssa/airflow-on-openshift.git \
    --set dags.gitSync.branch=main \
    --set dags.gitSync.subPath=example_dag
    ```

10. Create route for Airflow web UI

    ```bash
    oc create route edge \
    --service=airflow-webserver \
    --insecure-policy=Redirect \
    --port=8080
    ```

11. Create route for the Airflow Flower web UI

    ```bash
    oc create route edge \
    --service=airflow-flower \
    --insecure-policy=Redirect \
    --port=5555
    ```

12. Confirm routes

    ```bash
    oc get routes
    ```

## Usage

TODO

### Tests

## References

Steps originate from https://dsri.maastrichtuniversity.nl/docs/workflows-airflow/
