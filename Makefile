PACKAGE_NAME?=package
TAG?=v0.0.0-local
SHELL:=$(PREFIX)/bin/sh
VERSION:=$(shell `npm bin`/semver $(TAG))

build: \
	out/static/version.txt \
	out/static/openapi.yaml \
	out/static/openapi.json \
	out/static/index.html \
	out/npm/ \

rebuild: clean build

clean:
	rm -rf bin
	rm -rf out

out/static/version.txt:
	@mkdir --parents $(@D)
	echo $(VERSION) > $@

out/static/openapi.yaml: src/openapi.yaml
	@mkdir --parents $(@D)
	sed 's/0.0.0-local/$(VERSION)/' $< > $@

out/static/openapi.json: out/static/openapi.yaml
	@mkdir --parents $(@D)
	`npm bin`/js-yaml $< > $@

out/static/index.html: out/static/openapi.yaml
	@mkdir --parents $(@D)
	`npm bin`/redoc-cli bundle $< --output $@

out/npm/: out/static/openapi.yaml
	`npm bin`/oas3ts-generator package \
		--package-dir $@ \
		--package-name $(PACKAGE_NAME) \
		--request-type application/json \
		--response-type application/json \
		--response-type text/plain \
		--response-type application/octet-stream \
		$<
	( cd $@ ; npm install --unsafe-perm )


.PHONY: \
	build \
	rebuild \
	clean \
