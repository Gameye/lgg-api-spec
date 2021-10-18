SHELL:=$(PREFIX)/bin/sh
TAG?=v0.0.0-local
VERSION:=$(shell npx --yes semver $(TAG))
PACKAGE_NAME:=lgg-api-spec

rebuild: clean build

build: \
	out/static/version.txt \
	out/static/openapi.yaml \
	out/static/openapi.json \
	out/static/index.html \
	out/npm/ \

clean:
	rm -rf out

out/static/version.txt:
	@mkdir --parents $(@D)
	echo $(VERSION) > $@

out/static/openapi.yaml: src/openapi.yaml
	@mkdir --parents $(@D)
	sed 's/0.0.0-local/$(VERSION)/' $< > $@

out/static/openapi.json: out/static/openapi.yaml
	@mkdir --parents $(@D)
	npx --yes js-yaml $< > $@

out/static/index.html: out/static/openapi.yaml
	@mkdir --parents $(@D)
	`npm bin`/redoc-cli bundle $< --output $@

out/npm/: out/static/openapi.yaml
	`npm bin`/oas3ts-generator package \
		--package-dir $@ \
		--package-name @gameye/$(PACKAGE_NAME) \
		--request-type application/json \
		--response-type application/json \
		$<
	( cd $@ ; npm install )

.PHONY: \
	clean \
	build \
	rebuild \
