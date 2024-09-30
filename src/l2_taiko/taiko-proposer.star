PROPOSER_PORT_NUM = 1234

def launch(
    plan,
    data_dirpath,
    jwtsecret_path,
    el_context,
    cl_context,
    geth,
    prefunded_accounts,
    index,
):
    service = plan.add_service(
        name = "preconf-taiko-proposer-{0}".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/taiko-client:e2e",
            files = {
                data_dirpath: Directory(
                    persistent_key = "l2-execution-engine-data-{0}".format(index),
                ),
            },
            env_vars = {
                "PORT_PROVER_SERVER": "9876",
                "DISABLE_P2P_SYNC": "false",
                "L1_ENDPOINT_HTTP": el_context.rpc_http_url,
                "L1_ENDPOINT_WS": el_context.ws_url,
                "L1_BEACON_HTTP": cl_context.beacon_http_url,
                "ENABLE_PROVER": "false",
                "SGX_RAIKO_HOST": "",
                "PROVER_CAPACITY": "1",
                "L1_PROVER_PRIVATE_KEY": "",
                "TOKEN_ALLOWANCE": "",
                "MIN_ETH_BALANCE": "",
                "MIN_TAIKO_BALANCE": "",
                "PROVE_UNASSIGNED_BLOCKS": "false",
                "ENABLE_PROPOSER": "true",
                "PROVER_ENDPOINTS": "http://taiko_client_prover_relayer:9876",
                "TXPOOL_LOCALS": "",
                "EPOCH_MIN_TIP": "",
                "PROVER_SET": "",
            },
            ports = {
                "proposer-port": PortSpec(
                    number=1234, transport_protocol="TCP"
                )
            },
            entrypoint = ["/bin/sh", "-c"],
            cmd = [
                "taiko-client proposer --l1.ws={0} ".format(el_context.ws_url) +
                "--l2.http={0} ".format(geth.rpc_http_url) +
                "--l2.auth={0} ".format(geth.auth_url) +
                "--taikoL1=0x086f77C5686dfe3F2f8FE487C5f8d357952C8556 "+
                "--taikoL2=0x1670000000000000000000000000000000010001 " +
                "--jwtSecret={0} ".format(jwtsecret_path) +
                "--taikoToken=0x422A3492e218383753D8006C7Bfa97815B44373F " +
                "--l1.proposerPrivKey={0} ".format(prefunded_accounts[0].private_key) +
                "--l2.suggestedFeeRecipient=0x8e81D13339eE01Bb2080EBf9796c5F2e5621f7E1 " +
                "--tierFee.optimistic=1 " +
                "--tierFee.sgx=1 " +
                "--l1.blobAllowed " +
                "--tx.gasLimit=3000000",
            ],
        ),
    )

    proposer_url = "http://{0}:{1}".format(service.ip_address, PROPOSER_PORT_NUM)

    return struct(
        client_name="taiko-proposer",
        ip_addr=service.ip_address,
        proposer_port_num=PROPOSER_PORT_NUM,
        proposer_url=proposer_url,
        service_name=service.name,
    )
