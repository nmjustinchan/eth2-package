RPC_PORT_NUM = 8545
WS_PORT_NUM = 8546
DISCOVERY_PORT_NUM = 30306
ENGINE_RPC_PORT_NUM = 8551
METRICS_PORT_NUM = 6060

# The min/max CPU/memory that the execution node can use
EXECUTION_MIN_CPU = 100
EXECUTION_MIN_MEMORY = 512
EXECUTION_MAX_CPU = 1000
EXECUTION_MAX_MEMORY = 2048

def launch(
    plan,
    data_dirpath,
    index,
):
    service = plan.add_service(
        name = "preconf-taiko-geth-{0}".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/taiko-geth:e2e",
            files = {
                data_dirpath: Directory(
                    persistent_key = "l2-execution-engine-data-{0}".format(index),
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
                "--datadir={0}".format(data_dirpath),
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
            min_cpu = EXECUTION_MIN_CPU,
            max_cpu = EXECUTION_MAX_CPU,
            min_memory = EXECUTION_MIN_MEMORY,
            max_memory = EXECUTION_MAX_MEMORY,
        ),
    )

    http_url = "http://{0}:{1}".format(service.ip_address, RPC_PORT_NUM)
    ws_url = "ws://{0}:{1}".format(service.ip_address, WS_PORT_NUM)
    auth_url = "http://{0}:{1}".format(service.ip_address, ENGINE_RPC_PORT_NUM)

    return struct(
        client_name="taiko-geth",
        ip_addr=service.ip_address,
        rpc_port_num=RPC_PORT_NUM,
        ws_port_num=WS_PORT_NUM,
        engine_rpc_port_num=ENGINE_RPC_PORT_NUM,
        rpc_http_url=http_url,
        ws_url=ws_url,
        auth_url=auth_url,
        service_name=service.name,
    )
