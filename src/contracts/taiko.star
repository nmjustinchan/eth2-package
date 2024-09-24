shared_utils = import_module("../shared_utils/shared_utils.star")
input_parser = import_module("../package_io/input_parser.star")

def deploy(
    plan,
    taiko_params,
    el_uri,
):
    taiko = plan.run_sh(
        name="deploy-taiko-contract",
        run="script/test_deploy_on_l1.sh",
        image="nethswitchboard/taiko-deploy:e2e",
        env_vars={
            "PRIVATE_KEY": "0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
            "PROPOSER": "0x0000000000000000000000000000000000000000",
            "TAIKO_TOKEN": "0x0000000000000000000000000000000000000000",
            "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
            "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004",
            "TAIKO_L2_ADDRESS": "0x1670000000000000000000000000000000010001",
            "L2_SIGNAL_SERVICE": "0x1670000000000000000000000000000000000005",
            "CONTRACT_OWNER": "0x8943545177806ED17B9F23F0a21ee5948eCaa776",
            "PROVER_SET_ADMIN": "0x8943545177806ED17B9F23F0a21ee5948eCaa776",
            "TAIKO_TOKEN_PREMINT_RECIPIENT": "0x8943545177806ED17B9F23F0a21ee5948eCaa776",
            "TAIKO_TOKEN_NAME": "Taiko Token",
            "TAIKO_TOKEN_SYMBOL": "TKO",
            "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
            "L2_GENESIS_HASH": "0x7983c69e31da54b8d244d8fef4714ee7a8ed25d873ebef204a56f082a73c9f1e",
            "PAUSE_TAIKO_L1": "true",
            "PAUSE_BRIDGE": "true",
            "NUM_MIN_MAJORITY_GUARDIANS": "7",
            "NUM_MIN_MINORITY_GUARDIANS": "2",
            "TIER_PROVIDER": "devnet",
            "FORK_URL": el_uri,
        },
        wait=None,
        description="Deploying taiko smart contract",
    )
    plan.print("test")
    plan.print(taiko.output)
