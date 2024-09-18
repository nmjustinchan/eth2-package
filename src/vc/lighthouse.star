constants = import_module("../package_io/constants.star")
input_parser = import_module("../package_io/input_parser.star")
shared_utils = import_module("../shared_utils/shared_utils.star")
vc_shared = import_module("./shared.star")

RUST_BACKTRACE_ENVVAR_NAME = "RUST_BACKTRACE"
RUST_FULL_BACKTRACE_KEYWORD = "full"

VERBOSITY_LEVELS = {
    constants.GLOBAL_LOG_LEVEL.error: "error",
    constants.GLOBAL_LOG_LEVEL.warn: "warn",
    constants.GLOBAL_LOG_LEVEL.info: "info",
    constants.GLOBAL_LOG_LEVEL.debug: "debug",
    constants.GLOBAL_LOG_LEVEL.trace: "trace",
}


def get_config(
    el_cl_genesis_data,
    image,
    participant_log_level,
    global_log_level,
    beacon_http_url,
    cl_context,
    el_context,
    full_name,
    node_keystore_files,
    vc_min_cpu,
    vc_max_cpu,
    vc_min_mem,
    vc_max_mem,
    extra_params,
    extra_env_vars,
    extra_labels,
    tolerations,
    node_selectors,
    keymanager_enabled,
    network,
    electra_fork_epoch,
    port_publisher,
    vc_index,
):
    log_level = input_parser.get_client_log_level_or_default(
        participant_log_level, global_log_level, VERBOSITY_LEVELS
    )

    # Define the source and destination paths
    validator_keys_dirpath = shared_utils.path_join(
        constants.VALIDATOR_KEYS_DIRPATH_ON_SERVICE_CONTAINER,
        node_keystore_files.raw_keys_relative_dirpath,
    )
    validator_secrets_dirpath = shared_utils.path_join(
        constants.VALIDATOR_KEYS_DIRPATH_ON_SERVICE_CONTAINER,
        node_keystore_files.raw_secrets_relative_dirpath,
    )
    local_validator_keys_dirpath = "/root/validator_keys_" + vc_index
    local_validator_secrets_dirpath = "/root/validator_secrets_" + vc_index

    # Construct the copy commands
    copy_keys_cmd = "cp -r " + validator_keys_dirpath + " " + local_validator_keys_dirpath
    copy_secrets_cmd = "cp -r " + validator_secrets_dirpath + " " + local_validator_secrets_dirpath

    # Construct the lighthouse command
    cmd = [
        copy_keys_cmd + " && " + copy_secrets_cmd + " && lighthouse",
        "vc",
        "--debug-level=" + log_level,
        "--testnet-dir=" + constants.GENESIS_CONFIG_MOUNT_PATH_ON_CONTAINER,
        "--validators-dir=" + validator_keys_dirpath,
        "--secrets-dir=" + validator_secrets_dirpath,
        "--init-slashing-protection",
        "--beacon-nodes=" + beacon_http_url,
        "--suggested-fee-recipient=" + constants.VALIDATING_REWARDS_ACCOUNT,
        "--metrics",
        "--metrics-address=0.0.0.0",
        "--metrics-allow-origin=*",
        "--metrics-port={0}".format(vc_shared.VALIDATOR_CLIENT_METRICS_PORT_NUM),
        "--graffiti=" + full_name,
    ]

    keymanager_api_cmd = [
        "--http",
        "--http-port={0}".format(vc_shared.VALIDATOR_HTTP_PORT_NUM),
        "--http-address=0.0.0.0",
        "--http-allow-origin=*",
        "--unencrypted-http-transport",
    ]

    if len(extra_params):
        cmd.extend([param for param in extra_params])

    files = {
        constants.GENESIS_DATA_MOUNTPOINT_ON_CLIENTS: el_cl_genesis_data.files_artifact_uuid,
        constants.VALIDATOR_KEYS_DIRPATH_ON_SERVICE_CONTAINER: node_keystore_files.files_artifact_uuid,
    }
    env = {RUST_BACKTRACE_ENVVAR_NAME: RUST_FULL_BACKTRACE_KEYWORD}
    env.update(extra_env_vars)

    public_ports = {}
    public_keymanager_port_assignment = {}
    if port_publisher.vc_enabled:
        public_ports_for_component = shared_utils.get_public_ports_for_component(
            "vc", port_publisher, vc_index
        )
        public_port_assignments = {
            constants.METRICS_PORT_ID: public_ports_for_component[0]
        }
        public_keymanager_port_assignment = {
            constants.VALIDATOR_HTTP_PORT_ID: public_ports_for_component[1]
        }
        public_ports = shared_utils.get_port_specs(public_port_assignments)

    ports = {}
    ports.update(vc_shared.VALIDATOR_CLIENT_USED_PORTS)

    if keymanager_enabled:
        cmd.extend(keymanager_api_cmd)
        ports.update(vc_shared.VALIDATOR_KEYMANAGER_USED_PORTS)
        public_ports.update(
            shared_utils.get_port_specs(public_keymanager_port_assignment)
        )

    return ServiceConfig(
        image=image,
        ports=ports,
        public_ports=public_ports,
        cmd=cmd,
        env_vars=env,
        files=files,
        min_cpu=vc_min_cpu,
        max_cpu=vc_max_cpu,
        min_memory=vc_min_mem,
        max_memory=vc_max_mem,
        labels=shared_utils.label_maker(
            constants.VC_TYPE.lighthouse,
            constants.CLIENT_TYPES.validator,
            image,
            cl_context.client_name,
            extra_labels,
        ),
        tolerations=tolerations,
        node_selectors=node_selectors,
    )
