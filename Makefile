SHELL=/bin/bash
project = cmwtoken
account ?= metacmwtoken
dir ?= ${project}
# mainnet is https://wax.greymass.com
endpoint ?= "https://testnet.waxsweden.org"
docker = docker run -it -v $(CURDIR):/${project} -v home:/root winwinsoftware/wax-dev:latest
docker_nt = docker run -i -v $(CURDIR):/${project} -v home:/root winwinsoftware/wax-dev:latest

ifeq ($(OS),Windows_NT)
    MY_OS := Windows
else
    MY_OS := $(strip $(shell uname))
endif

all: build deploy

build:
	$(docker) bash -c "mkdir -p /root/${project} && cd /root/${project} && \
		cmake /${project} && make VERBOSE=1 && rm -rf /${project}/cmake-build-prod || true && cp -Rap /root/${project} /${project}/cmake-build-prod"
clean:
	$(docker) bash -c "rm -rf /root/${project} || true && rm -rf /${project}/cmake-build-prod"
create:
	$(docker) bash -c 'if [ ! -f /root/wallet ]; then cleos wallet create -f /root/wallet; else echo "wallet already created"; exit -1; fi'
addkey:
	$(docker) bash -c 'cleos wallet unlock < /root/wallet; cleos wallet import'
deploy:
	$(docker) bash -c "cleos wallet unlock < /root/wallet; cleos -u $(endpoint) set contract $(account) /$(project)/cmake-build-prod $(project).wasm $(project).abi -p $(account)@active"
addcode:
	$(docker) bash -c "cleos wallet unlock < /root/wallet; cleos -u $(endpoint) set account permission $(account) active --add-code"
console:
	$(docker) bash
account:
	$(docker) cleos -u $(endpoint) get account $(account) -j
