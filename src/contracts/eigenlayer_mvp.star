def deploy(
    plan,
    el_rpc_url,
    contract_owner,
):
    eigenlayer_mvp = plan.run_sh(
        name="deploy-eigenlayer-contract",
        description="Deploying eigenlayer mvp contract",
        run="scripts/deployment/deploy_eigenlayer_mvp.sh > /tmp/eigenlayer-mvp-output.txt",
        image="nethswitchboard/avs-deploy:e2e",
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
        },
        wait=None,
        store=[
            "/tmp/eigenlayer-mvp-output.txt"
        ],
    )
