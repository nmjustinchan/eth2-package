constants = import_module("../package_io/constants.star")
input_parser = import_module("../package_io/input_parser.star")
shared_utils = import_module("../shared_utils/shared_utils.star")

def launch(
    plan,
    el_context,
    cl_context,
    taiko_contract_context,
):
    geth = plan.add_service(
        name = "taiko-geth-preconf",
        config = ServiceConfig(
            image = "nethswitchboard/taiko-geth:e2e",
            files = {
                "/data/taiko-geth": Directory(
                    persistent_key = "l2-execution-engine-data",
                ),
            },
            ports = {
                "metrics": PortSpec(
                    number=6060, transport_protocol="TCP"
                ),
                "http": PortSpec(
                    number=8545, transport_protocol="TCP"
                ),
                "ws": PortSpec(
                    number=8546, transport_protocol="TCP"
                ),
                "discovery": PortSpec(
                    number=30306, transport_protocol="TCP"
                ),
                "discovery-udp": PortSpec(
                    number=30306, transport_protocol="UDP"
                ),
                "authrpc": PortSpec(
                    number=8551, transport_protocol="TCP"
                ),
            },
            cmd = [
                "--taiko",
                "--networkid=167",
                "--gcmode=archive",
                "--datadir=/data/taiko-geth",
                "--metrics",
                "--metrics.expensive",
                "--metrics.addr=0.0.0.0",
                "--authrpc.addr=0.0.0.0",
                "--authrpc.vhosts=*",
                "--http",
                "--http.api=debug,eth,net,web3,txpool,taiko",
                "--http.addr=0.0.0.0",
                "--http.vhosts=*",
                "--ws",
                "--ws.api=debug,eth,net,web3,txpool,taiko",
                "--ws.addr=0.0.0.0",
                "--ws.origins=*",
                "--gpo.ignoreprice=100000000",
                "--port=30306",
                "--discovery.port=30306",
            ],
        ),
    )
    plan.print(geth)

    driver = plan.add_service(
        name = "taiko-driver",
        config = ServiceConfig(
            image = "nethswitchboard/taiko-client:e2e",
            files = {
                "/data/taiko-geth": Directory(
                    persistent_key = "l2-execution-engine-data",  # This will be the persistent data volume
                ),
            },
            ports = {
                "driver-port": PortSpec(
                    number=1235, transport_protocol="TCP"
                )
            },
            entrypoint = ["/bin/sh", "-c"],
            cmd = [
                "taiko-client driver --l1.ws=" + el_context.ws_url + " --l2.ws ws://taiko-geth-preconf:8546 --l1.beacon=" + cl_context.beacon_http_url + " --l2.auth=http://taiko-geth-preconf:8551 --taikoL1=0x086f77C5686dfe3F2f8FE487C5f8d357952C8556 --taikoL2=0x1670000000000000000000000000000000010001 --jwtSecret /data/taiko-geth/geth/jwtsecret --verbosity 4",
            ],
        ),
    )

    proposer = plan.add_service(
        name = "taiko-proposer",
        config = ServiceConfig(
            image = "nethswitchboard/taiko-client:e2e",
            files = {
                "/data/taiko-geth": Directory(
                    persistent_key = "l2-execution-engine-data",  # This will be the persistent data volume
                ),
            },
            ports = {
                "proposer-port": PortSpec(
                    number=1234, transport_protocol="TCP"
                )
            },
            entrypoint = ["/bin/sh", "-c"],
            cmd = [
                "taiko-client proposer --l1.ws=" + el_context.ws_url + " --l2.http=http://taiko-geth-preconf:8545 --l2.auth=http://taiko-geth-preconf:8551 --taikoL1=0x086f77C5686dfe3F2f8FE487C5f8d357952C8556 --taikoL2=0x1670000000000000000000000000000000010001 --jwtSecret=/data/taiko-geth/geth/jwtsecret --taikoToken=0x422A3492e218383753D8006C7Bfa97815B44373F --l1.proposerPrivKey=0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31 --l2.suggestedFeeRecipient=0x8e81D13339eE01Bb2080EBf9796c5F2e5621f7E1 --tierFee.optimistic=1 --tierFee.sgx=1 --l1.blobAllowed --tx.gasLimit=3000000",
            ],
        ),
    )
