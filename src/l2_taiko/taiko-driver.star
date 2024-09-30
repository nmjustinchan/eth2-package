DRIVER_PORT_NUM = 1235

def launch(
    plan,
    data_dirpath,
    jwtsecret_path,
    el_context,
    cl_context,
    geth,
    index,
):
    service = plan.add_service(
        name = "preconf-taiko-driver-{0}".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/taiko-client:e2e",
            files = {
                data_dirpath: Directory(
                    persistent_key = "l2-execution-engine-data-{0}".format(index),
                ),
            },
            ports = {
                "driver-port": PortSpec(
                    number=1235, transport_protocol="TCP"
                )
            },
            entrypoint = ["/bin/sh", "-c"],
            cmd = [
                "taiko-client driver --l1.ws={0} ".format(el_context.ws_url) +
                "--l2.ws={0} ".format(geth.ws_url) +
                "--l1.beacon={0} ".format(cl_context.beacon_http_url) +
                "--l2.auth={0} ".format(geth.auth_url) +
                "--taikoL1=0x086f77C5686dfe3F2f8FE487C5f8d357952C8556 " +
                "--taikoL2=0x1670000000000000000000000000000000010001 " +
                "--jwtSecret={0} ".format(jwtsecret_path) +
                "--verbosity=4"
            ],
        ),
    )

    driver_url = "http://{0}:{1}".format(service.ip_address, DRIVER_PORT_NUM)

    return struct(
        client_name="taiko-driver",
        ip_addr=service.ip_address,
        driver_port_num=DRIVER_PORT_NUM,
        driver_url=driver_url,
        service_name=service.name,
    )
