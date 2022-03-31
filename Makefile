SHELL=/bin/bash
project = metaverse
account ?= metacmwtoken
dir ?= ${project}
# mainnet is https://wax.greymass.com
endpoint ?= "https://testnet.waxsweden.org"
docker = docker run -it -v $(CURDIR):/wax -v home:/root waxteam/dev

ifeq ($(OS),Windows_NT)
    MY_OS := Windows
else
    MY_OS := $(strip $(shell uname))
endif

all: build deploy

build:
	$(docker) bash -c "mkdir -p /root/build && cd /root/build && cmake /wax && make VERBOSE=1 && rm -rf /wax/$(project) || true && cp -Rap /root/build /wax/$(project)"
build-test:
	$(docker) bash -c "mkdir -p /root/build && cd /root/build && cmake -DCMAKE_BUILD_TYPE=test /wax && VERBOSE=1 make && rm -rf /wax/$(project) || true && cp -Rap /root/build /wax/$(project)"
build-assets:
	$(docker) bash -c "mkdir -p /root/build && cd /root/build && cmake -DCMAKE_BUILD_TYPE=assets /wax && VERBOSE=1 make && rm -rf /wax/$(project) || true && cp -Rap /root/build /wax/$(project)"
clean:
	$(docker) bash -c "rm -rf /root/build"
	rm -rf $(project)
create:
	$(docker) if [ ! -f /root/wallet ]; then cleos wallet create -f /root/wallet; else echo "wallet alread created"; exist -1; fi
addkey:
	$(docker) bash -c 'cleos wallet unlock < /root/wallet; cleos wallet import'
deploy:
	$(docker) bash -c "cleos wallet unlock < /root/wallet; cleos -u $(endpoint) set contract $(account) /wax/$(project)/ -p $(account)@active"
deploy-mainnet:
	$(docker) bash -c "cleos wallet unlock < /root/wallet; cleos -u $(endpoint) set contract $(account) /wax/$(project)/ -p $(account)@active"
addcode:
	$(docker) bash -c "cleos wallet unlock < /root/wallet; cleos -u $(endpoint) set account permission $(account) active --add-code"
console:
	$(docker) bash
account:
	$(docker) cleos -u $(endpoint) get account $(account) -j