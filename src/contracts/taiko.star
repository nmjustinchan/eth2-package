def deploy(
    plan,
    el_rpc_url,
    contract_owner,
):
    taiko = plan.run_sh(
        name="deploy-taiko-contract",
        run="script/test_deploy_on_l1.sh > /tmp/taiko-output.txt",
        image="nethswitchboard/taiko-deploy:e2e",
        env_vars={
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "PROPOSER": "0x0000000000000000000000000000000000000000",
            "TAIKO_TOKEN": "0x0000000000000000000000000000000000000000",
            "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
            "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
            "TAIKO_L2_ADDRESS": "0x1670000000000000000000000000000000010001",
            "L2_SIGNAL_SERVICE": "0x1670000000000000000000000000000000000005",
            "CONTRACT_OWNER": contract_owner.address,
            "PROVER_SET_ADMIN": contract_owner.address,
            "TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
            "TAIKO_TOKEN_NAME": "Taiko Token",
            "TAIKO_TOKEN_SYMBOL": "TKO",
            "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
            "L2_GENESIS_HASH": "0x7983c69e31da54b8d244d8fef4714ee7a8ed25d873ebef204a56f082a73c9f1e",
            "PAUSE_TAIKO_L1": "true",
            "PAUSE_BRIDGE": "true",
            "NUM_MIN_MAJORITY_GUARDIANS": "7",
            "NUM_MIN_MINORITY_GUARDIANS": "2",
            "TIER_PROVIDER": "devnet",
            "FORK_URL": el_rpc_url,
        },
        wait=None,
        description="Deploying taiko smart contract",
        store=[
            "/tmp/taiko-output.txt"
        ],
    )
