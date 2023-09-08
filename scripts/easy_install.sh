#/bin/sh

APP_NAME=${APP_NAME:-airflow}

check_bins(){

    echo "Checking for bins"
    echo "================="
    which oc || echo "oc is not in PATH"
    which helm || echo "helm is not in PATH"
}

init_oc(){
    # get project
    PROJECT=$(oc project -q)
    OC_USER=$(oc whoami)

    echo
    echo "Verify OpenShift Info"
    echo "Press Ctrl + C to exit"
    echo "======================"
    echo -e "Project:  ${PROJECT}"
    echo -e "User:\t  ${OC_USER}"

    sleep 8
}

helm_install(){
    # add helm repo
    helm repo add apache-airflow https://airflow.apache.org

    # get openshift uid/gid range
    CHART_UID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.uid-range']}" | sed "s@/.*@@")
    CHART_GID=$(oc get project ${PROJECT} -o jsonpath="{['metadata.annotations.openshift\.io/sa\.scc\.supplemental-groups']}" | sed "s@/.*@@")

    echo "UID/GID: $CHART_UID/$CHART_GID"

    # install via helm
    helm upgrade \
        --install ${APP_NAME} apache-airflow/airflow \
        --namespace ${PROJECT} \
        --version 1.10.0 \
        --set uid=${CHART_UID} \
        --set gid=${CHART_GID} \
        --set redis.securityContext.runAsUser=${CHART_UID} \
        --values ./example_values.yaml
}

setup_routes(){
# create route for airflow
    oc create route edge \
        --service=${APP_NAME}-webserver \
        --insecure-policy=Redirect \
        --port=8080

    # create route for airflow flower
    oc create route edge \
        --service=${APP_NAME}-flower \
        --insecure-policy=Redirect \
        --port=5555

    # confirm routes
    oc get routes
}

check_bins
init_oc
helm_install
setup_routes
