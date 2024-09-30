def deploy(
    plan,
    el_rpc_url,
    beacon_genesis_timestamp,
    contract_owner,
):
    preconf_avs = plan.run_sh(
        name="deploy-preconf-avs-contract",
        description="Deploying preconf avs contract",
        run="scripts/deployment/deploy_avs.sh > /tmp/avs-output.txt",
        image="nethswitchboard/avs-deploy:e2e",
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "BEACON_GENESIS_TIMESTAMP": beacon_genesis_timestamp,
            "BEACON_BLOCK_ROOT_CONTRACT": "0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02",
            "SLASHER": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
            "AVS_DIRECTORY": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
            "TAIKO_L1": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
            "TAIKO_TOKEN": "0x422A3492e218383753D8006C7Bfa97815B44373F",
        },
        wait=None,
        store=[
            "/tmp/avs-output.txt"
        ],
    )
