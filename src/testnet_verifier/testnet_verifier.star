IMAGE_NAME = "marioevz/merge-testnet-verifier:latest"
SERVICE_ID = "testnet-verifier"

# We use Docker exec commands to run the commands we need, so we override the default
SYNCHRONOUS_ENTRYPOINT_ARGS = [
	"sleep",
	"999999",
]


# this is broken check - https://github.com/ethereum/merge-testnet-verifier/issues/4
def launch_testnet_verifier(params, el_client_contexts, cl_client_contexts):
	config = get_asynchronous_verification_config(params, el_client_contexts, cl_client_contexts)
	add_service(SERVICE_ID, config)


def run_synchronous_testnet_verification(params, el_client_contexts, cl_client_contexts):
	config = get_synchronous_verification_config()
	add_service(SERVICE_ID, config)

	command = get_cmd(params, el_client_contexts, cl_client_contexts, True)
	exec(SERVICE_ID, command)


def get_cmd(params, el_client_contexts, cl_client_contexts, add_binary_name):
	command = []

	if add_binary_name:
		command.append("./merge_testnet_verifier")

	command.append("--ttd")
	command.append("0")

	for el_client_context in el_client_contexts:
		command.append("--client")
		command.append("{0},http://{1}:{2}".format(el_client_context.client_name, el_client_context.ip_addr, el_client_context.rpc_port_num))

	for cl_client_context in cl_client_contexts:
		command.append("--client")
		command.append("{0},http://{1}:{2}".format(cl_client_context.client_name, cl_client_context.ip_addr, cl_client_context.http_port_num))

	command.append("--ttd-epoch-limit")
	command.append("0")
	command.append("--verif-epoch-limit")
	command.append("{0}".format(params.verifications_epoch_limit))

	return command




def get_asynchronous_verification_config(params, el_client_contexts, cl_client_contexts):
	commands = get_cmd(params, el_client_contexts, cl_client_contexts, False)
	return struct(
		image = IMAGE_NAME,
		cmd = commands,
		# TODO remove this when ports is optional in add_service
		ports = {},
	)


def get_synchronous_verification_config():
	return struct(
		image = IMAGE_NAME,
		entrypoint = SYNCHRONOUS_ENTRYPOINT_ARGS,
		# TODO remove this when ports is optional in add_service
		ports = {},
	)