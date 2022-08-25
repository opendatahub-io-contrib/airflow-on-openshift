#/bin/sh

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
}

check_bins
init_oc
helm_install