constants = import_module("../package_io/constants.star")
input_parser = import_module("../package_io/input_parser.star")
shared_utils = import_module("../shared_utils/shared_utils.star")

def launch(
    plan,
    chain_id,
    el_context,
    cl_context,
    taiko_stack,
    mev_boost_context,
    prefunded_accounts,
    validator_bls_private_key,
    validator_index,
    index,
):
    mev_boost_url = "http://{0}:{1}".format(
        mev_boost_context.private_ip_address, mev_boost_context.port
    )

    avs = plan.add_service(
        name = "taiko-preconf-avs-{0}".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/avs-node:e2e",
            env_vars={
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
                "AVS_DIRECTORY_CONTRACT_ADDRESS": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
                "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": "0x1912A7496314854fB890B1B88C0f1Ced653C1830",
                "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": "0x9D2ea2038CF6009F1Bc57E32818204726DfA63Cd",
                "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": "0xaDe68b4b6410aDB1578896dcFba75283477b6b01",
                "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
                "VALIDATOR_BLS_PRIVATEKEY": validator_bls_private_key,
                "TAIKO_CHAIN_ID": "167",
                "L1_CHAIN_ID": chain_id,
                "TAIKO_L1_ADDRESS": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
                "VALIDATOR_INDEX": validator_index,
                "TAIKO_PROPOSER_URL": taiko_stack.proposer_url,
                "TAIKO_DRIVER_URL": taiko_stack.driver_url,
                "MEV_BOOST_URL": mev_boost_url,
                "L1_WS_RPC_URL": el_context.ws_url,
                "L1_BEACON_URL": cl_context.beacon_http_url,
                "ENABLE_P2P": "false",
                "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info",
            },
        ),
    )

    # plan.exec(
    #     name="taiko-preconf-avs",
    #     description="Starting AVS",
    #     run="--add-validator",
    #     image="nethswitchboard/avs-node:e2e",
    #     env_vars={
    #         "AVS_NODE_ECDSA_PRIVATE_KEY": "0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
    #     },
    # )
