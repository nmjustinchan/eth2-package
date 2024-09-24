constants = import_module("../package_io/constants.star")
input_parser = import_module("../package_io/input_parser.star")
shared_utils = import_module("../shared_utils/shared_utils.star")

def launch(
    plan,
    chain_id,
    el_context,
    cl_context,
    taiko_contract_context,
):
    avs = plan.add_service(
        name = "taiko-preconf-avs",
        config = ServiceConfig(
            image = "nethswitchboard/avs-node:e2e",
            env_vars={
                # prefunded account 0x8943545177806ED17B9F23F0a21ee5948eCaa776
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
                "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
                "AVS_DIRECTORY_CONTRACT_ADDRESS": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
                "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": "0x1912A7496314854fB890B1B88C0f1Ced653C1830",
                "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": "0x9D2ea2038CF6009F1Bc57E32818204726DfA63Cd",
                "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": "0xaDe68b4b6410aDB1578896dcFba75283477b6b01",
                "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
                "VALIDATOR_BLS_PRIVATEKEY": "3219c83a76e82682c3e706902ca85777e703a06c9f0a82a5dfa6164f527c1ea6",
                "TAIKO_CHAIN_ID": "167",
                "L1_CHAIN_ID": chain_id,
                "TAIKO_L1_ADDRESS": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
                "VALIDATOR_INDEX": "1",
                "TAIKO_PROPOSER_URL": "http://139.162.249.67:1234",
                "TAIKO_DRIVER_URL": "http://139.162.249.67:1235",
                "MEV_BOOST_URL": "http://139.162.249.67:33477",
                "L1_WS_RPC_URL": el_context.ws_url,
                "L1_BEACON_URL": cl_context.beacon_http_url,
                "ENABLE_P2P": "false",
                "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info",
            },
        ),
    )
