PKG_ID := hermes-agent

.PHONY: all build s9pk clean

all: s9pk

build:
	npm install
	npm run build:ts

s9pk: build
	start-sdk pack .

clean:
	rm -rf dist
	rm -f $(PKG_ID).s9pk image.tar