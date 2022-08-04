# Airflow on OpenShift

Get started with Airflow on OpenShift

## Tutorial Result

Airflow 2.2.4 on OpenShift 4.9 using Helm chart 1.5.1 with an example DAG deployed.

## Prerequisites

1. OpenShift cluster with admin permissions
2. Install `oc` CLI tool
3. Install [Helm](https://helm.sh/)

## Setup

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

## References

Steps originate from https://dsri.maastrichtuniversity.nl/docs/workflows-airflow/
