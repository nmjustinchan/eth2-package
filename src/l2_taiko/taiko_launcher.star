geth_launcher = import_module("./taiko-geth.star")
driver_launcher = import_module("./taiko-driver.star")
proposer_launcher = import_module("./taiko-proposer.star")

# The dirpath of the execution data directory on the client container
EXECUTION_DATA_DIRPATH_ON_CLIENT_CONTAINER = "/data/taiko-geth"

def launch(
    plan,
    el_context,
    cl_context,
    prefunded_accounts,
    index,
):
    data_dirpath = EXECUTION_DATA_DIRPATH_ON_CLIENT_CONTAINER + "-" + str(index)
    jwtsecret_path = data_dirpath + "/geth/jwtsecret"

    # Launch geth
    geth = geth_launcher.launch(
        plan,
        data_dirpath,
        index,
    )

    # Launch driver
    driver = driver_launcher.launch(
        plan,
        data_dirpath,
        jwtsecret_path,
        el_context,
        cl_context,
        geth,
        index,
    )

    # Launch proposer
    proposer = proposer_launcher.launch(
        plan,
        data_dirpath,
        jwtsecret_path,
        el_context,
        cl_context,
        geth,
        prefunded_accounts,
        index,
    )

    return struct(
        client_name="taiko-stack",
        rpc_http_url=geth.rpc_http_url,
        ws_url=geth.ws_url,
        auth_url=geth.auth_url,
        driver_url=driver.driver_url,
        proposer_url=proposer.proposer_url,
    )
