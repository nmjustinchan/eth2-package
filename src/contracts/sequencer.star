shared_utils = import_module("../shared_utils/shared_utils.star")
input_parser = import_module("../package_io/input_parser.star")

def deploy(
    plan,
    network_params,
    el_uri,
):
    sequencer = plan.run_sh(
        name="deploy-add-to-sequencer",
        description="Deploying add to sequencer",
        run="scripts/deployment/add_to_sequencer.sh",
        image="nethswitchboard/taiko-deploy:e2e",
        env_vars = {
            "PRIVATE_KEY": "0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
            "FORK_URL": el_uri,
            "PROXY_ADDRESS": "0x3c0e871bB7337D5e6A18FDD73c4D9e7567961Ad3",
            "ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
            "ENABLED": "true",
        },
        wait=None,
    )

    plan.print(sequencer.output)
