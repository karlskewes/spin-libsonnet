# spin-libsonnet

JSONNET := jsonnet
JSONNETFMT := jsonnetfmt
OUTPUT_DIR := manifests

.PHONY: all
all: help

.PHONY: clean
clean:  ## Removes any manifests from previous builds
	@for dir in $(shell find * -type d -path '*/$(OUTPUT_DIR)'); do \
		echo "Deleting old output directory $${dir}"; \
		rm -rf "$${dir}"; \
	done

.PHONY: dep
dep:  ## Install dependencies
	go install github.com/google/go-jsonnet/cmd/jsonnet@latest
	go install github.com/google/go-jsonnet/cmd/jsonnetfmt@latest
	go install github.com/google/go-jsonnet/cmd/jsonnet-lint@latest
	go install github.com/spinnaker/spin@latest

.PHONY: build
build: ## Generate JSON manifests for `spin save`
	$(JSONNET) --version
	export failed=0; \
	for dir in $(shell find * -type d | \
		grep -v '\(tests\|$(OUTPUT_DIR)\)'); do \
			echo "Building $${dir}"; \
			cd "$${dir}"; \
			for f in $$(find * -name '*.jsonnet'); do \
				jsonnet "$${f}" > /dev/null || export failed=1; \
				jsonnet \
				  --create-output-dirs \
				  --output-file "$(OUTPUT_DIR)/$${f%%.jsonnet}.json" \
					"$${f}" \
					|| export failed=1; \
			done; \
			cd ..; \
	done; \
	if [ "$$failed" -eq 1 ]; then \
		exit 1; \
	fi

.PHONY: test
test: ## Test for formatting and linting errors
	$(JSONNET) --version
	export failed=0; \
	for f in $$(find * -name '*.jsonnet' -o -name '*.libsonnet'); do \
		jsonnet "$${f}" > /dev/null || export failed=1; \
		jsonnetfmt --test "$${f}" || export failed=1; \
		jsonnet-lint "$${f}" || export failed=1; \
	done; \
	if [ "$$failed" -eq 1 ]; then \
		exit 1; \
	fi

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
