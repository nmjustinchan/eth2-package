taiko_contract_deployer = import_module("./taiko.star")
eigenlayer_contract_deployer = import_module("./eigenlayer_mvp.star")
avs_contract_deployer = import_module("./preconf_avs.star")
sequencer_contract_deployer = import_module("./sequencer.star")

def deploy(
    plan,
    final_genesis_timestamp,
    el_context,
    prefunded_accounts,
):
    # Get el rpc url
    el_rpc_url = el_context.rpc_http_url

    # Get first prefunded account
    first_prefunded_account = prefunded_accounts[0]

    # Deploy taiko contracts
    taiko_contract_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
    )

    # Deploy eigenlayer mvp contracts
    eigenlayer_contract_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
    )

    # Get beacon genesis timestamp for avs contracts
    beacon_genesis_timestamp = plan.run_python(
        description="Getting final beacon genesis timestamp",
        run="""
import sys
new = int(sys.argv[1]) + 20
print(new, end="")
            """,
        args=[str(final_genesis_timestamp)],
        store=[StoreSpec(src="/tmp", name="beacon-genesis-timestamp")],
    )

    # Deploy avs contracts
    avs_contract_deployer.deploy(
        plan,
        el_rpc_url,
        beacon_genesis_timestamp.output,
        first_prefunded_account,
    )

    # Deploy add to sequencer contracts
    sequencer_contract_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
    )
