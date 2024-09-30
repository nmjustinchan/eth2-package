def deploy(
    plan,
    el_rpc_url,
    contract_owner,
):
    sequencer = plan.run_sh(
        name="deploy-add-to-sequencer",
        run="script/add_to_sequencer.sh > /tmp/sequencer-output.txt",
        image="nethswitchboard/taiko-deploy:e2e",
        env_vars={
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "PROXY_ADDRESS": "0x3c0e871bB7337D5e6A18FDD73c4D9e7567961Ad3",
            "ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
            "ENABLED": "true",
        },
        wait=None,
        description="Deploying add to sequencer",
        store=[
            "/tmp/sequencer-output.txt"
        ],
    )
