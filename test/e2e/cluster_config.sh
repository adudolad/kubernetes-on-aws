#!/bin/bash
set -euo pipefail
set -x

cat <<EOF
clusters:
- alias: ${CLUSTER_ALIAS}
  api_server_url: ${API_SERVER_URL}
  channel: ${1}
  config_items:
    zmon_root_account_role: ${ZMON_ROOT_ACCOUNT_ROLE}
    experimental_new_etcd_stack: "true"
    audittrail_root_account_role: ${AUDITTRAIL_ROOT_ACCOUNT_ROLE}
    apiserver_etcd_prefix: /registry-${LOCAL_ID}
    apiserver_business_partner_ids: ${APISERVER_BUSINESS_PARTNER_IDS}
    etcd_s3_backup_bucket: zalando-kubernetes-etcd-${AWS_ACCOUNT}-${REGION}
    etcd_endpoints: "${ETCD_ENDPOINTS}"
    etcd_client_ca_cert: "${ETCD_CLIENT_CA_CERT}"
    etcd_client_ca_key: "${ETCD_CLIENT_CA_KEY}"
    etcd_scalyr_key: "${ETCD_SCALYR_KEY}"
    docker_meta_url: https://docker-meta.stups-test.zalan.do
    service_account_private_key: ${SERVICE_ACCOUNT_PRIVATE_KEY}
    vpa_enabled: "true"
    lightstep_token: "${LIGHTSTEP_TOKEN}"
    okta_auth_issuer_url: "${OKTA_AUTH_ISSUER_URL}"
    zmon_agent_replicas: '0'
    zmon_aws_agent_replicas: '0'
    zmon_redis_replicas: '0'
    zmon_scheduler_replicas: '0'
    zmon_worker_replicas: '0'
    node_pool_feature_enabled: "true"
    enable_rbac: "true"
    dynamodb_service_link_enabled: "false"
    skipper_ingress_refuse_payload: "refused-pattern-1[cf724afc]refused-pattern-2"
    efs_id: ${EFS_ID}
    webhook_id: ${INFRASTRUCTURE_ACCOUNT}:${REGION}:kube-aws-test
    kube_aws_ingress_controller_nlb_enabled: "true"
    nlb_switch: "pre"
    vm_dirty_bytes: 134217728
    vm_dirty_background_bytes: 67108864
    coredns_max_upsteam_concurrency: 30
    ebs_root_volume_size: "550" # required by the limitRanger e2e tests (needs 500Gi ephemoral storage) https://github.com/kubernetes/kubernetes/blob/v1.18.3/test/e2e/scheduling/limit_range.go#L59
    routegroups_validation: "enabled"
    stackset_routegroup_support_enabled: "true"
    stackset_ingress_source_switch_ttl: "1m"
    stackset_legacy_hpa_field_enabled: "true"
    stackset_legacy_hpa_field_crd_enabled: "true"
    teapot_admission_controller_daemonset_reserved_cpu: "518m"
  criticality_level: 1
  environment: e2e
  id: ${CLUSTER_ID}
  infrastructure_account: ${INFRASTRUCTURE_ACCOUNT}
  lifecycle_status: ${2}
  local_id: ${LOCAL_ID}
  node_pools:
  - discount_strategy: none
    instance_types: ["m6g.large"]
    name: default-master
    profile: master-default
    min_size: 1
    max_size: 2
  - discount_strategy: none
    instance_types: ["m5.xlarge"]
    name: default-worker-splitaz
    profile: worker-splitaz
    min_size: 0
    max_size: 21
    config_items:
      cpu_manager_policy: static
  - discount_strategy: none
    instance_types: ["m5.xlarge"]
    config_items:
      availability_zones: "eu-central-1a"
      scaling_priority: "-100"
    name: worker-limit-az
    profile: worker-splitaz
    min_size: 0
    max_size: 21
  - discount_strategy: none
    instance_types: ["m5d.xlarge"]
    name: worker-instance-storage
    profile: worker-splitaz
    min_size: 0
    max_size: 21
  - discount_strategy: none
    instance_types: ["m5.xlarge"]
    name: worker-combined
    profile: worker-combined
    config_items:
      labels: dedicated=worker-combined
      taints: dedicated=worker-combined:NoSchedule
    min_size: 0
    max_size: 21
  - discount_strategy: spot
    instance_types: ["c5.large", "c5a.large", "m5a.large", "m5.large", "t3.large"]
    min_size: 0
    max_size: 9
    profile: worker-splitaz
    name: skipper-ingress-node
    config_items:
      labels: dedicated=skipper-ingress
      taints: dedicated=skipper-ingress:NoSchedule
  - discount_strategy: spot
    instance_types: ["m5a.large", "m5.large", "m5.xlarge", "m5a.xlarge", "t3.large", "t3.xlarge", "c5a.large", "c5a.xlarge"]
    min_size: 0
    max_size: 3
    profile: worker-splitaz
    name: worker-node-tests
    config_items:
      labels: dedicated=node-tests
      taints: dedicated=node-tests:NoSchedule
  - discount_strategy: spot
    instance_types: ["p2.xlarge", "p3.2xlarge", "g3s.xlarge", "g3.4xlarge", "g4dn.xlarge", "g4dn.2xlarge", "g4dn.4xlarge"]
    name: worker-gpu
    profile: worker-splitaz
    min_size: 0
    max_size: 6
    config_items:
      availability_zones: "eu-central-1a,eu-central-1b"
      labels: zalando.org/nvidia-gpu=tesla
      taints: nvidia.com/gpu=present:NoSchedule
      scaling_priority: "-100"
  - discount_strategy: none
    instance_types: ["g4dn.xlarge"]
    name: worker-gpu-on-demand
    profile: worker-splitaz
    min_size: 0
    max_size: 6
    config_items:
      availability_zones: "eu-central-1a,eu-central-1b"
      labels: zalando.org/nvidia-gpu=tesla
      taints: nvidia.com/gpu=present:NoSchedule
      scaling_priority: "-200"
  - discount_strategy: none
    instance_types: ["m5.xlarge"]
    min_size: 0
    max_size: 3
    profile: worker-splitaz
    name: node-reboot-tests
    config_items:
      labels: dedicated=node-reboot-tests
      taints: dedicated=node-reboot-tests:NoSchedule
  provider: zalando-aws
  region: ${REGION}
  owner: '${OWNER}'
EOF
