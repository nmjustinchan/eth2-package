constants = import_module("../package_io/constants.star")
input_parser = import_module("../package_io/input_parser.star")
shared_utils = import_module("../shared_utils/shared_utils.star")

def launch(
    plan,
    el_context,
    cl_context,
):
    plan.add_service(
        name = "taiko-geth",
        config = ServiceConfig(
            image = "nethswitchboard/taiko-geth:e2e",
            ports = {
                "6060":"6060",
                "8547":"8545",
                "8548":"8546",
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
            ]
        )
    )

    plan.add_service(
        name = "taiko-driver",
        config = ServiceConfig(
            image = "nethswitchboard/taiko-client:e2e",
            ports = {
                "1235":"1235",
            },
            cmd = [
                "--taiko",
                "taiko-client driver",
                "--l1.ws=" + el_context[0].ws_url,
                "--l2.ws ws://taiko-geth:8546",
                "--l1.beacon" + cl_context[0].beacon_http_url,
                "--l2.auth http://taiko-geth:8551",
                "--taikoL1=0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
                "--taikoL2=0x1670000000000000000000000000000000010001",
                "--jwtSecret /data/taiko-geth/geth/jwtsecret",
                "--verbosity 4",
            ]
        )
    )

    plan.add_service(
        name = "taiko-proposer",
        config = ServiceConfig(
            image = "nethswitchboard/taiko-client:e2e",
            ports = {
                "1234":"1234",
            },
            cmd = [
                "--l1.ws=" + el_context[0].ws_url,
                "--l2.http http://taiko-geth:8545"
                "--l2.auth http://taiko-geth:8551",
                "--taikoL1=0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
                "--taikoL2=0x1670000000000000000000000000000000010001",
                "--jwtSecret=/data/taiko-geth/geth/jwtsecret",
                "--taikoToken=0x422A3492e218383753D8006C7Bfa97815B44373F",
                "--l1.proposerPrivKey=0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
                "--l2.suggestedFeeRecipient=0x8e81D13339eE01Bb2080EBf9796c5F2e5621f7E1",
                "--proverEndpoints ${PROVER_ENDPOINTS}",
                "--tierFee.optimistic=1",
                "--tierFee.sgx=1",
                "--l1.blobAllowed",
                "--tx.gasLimit=3000000",
            ]
        )
    )
