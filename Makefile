.DEFAULT_GOAL := all

formatting: ## Fix the formatting of md files
	@npx prettier --write .

doctoc: ## Update the tables of contents
	@git grep -L 'DOCTOC SKIP' **/*.md | xargs npx doctoc

all: doctoc formatting

help: ## This help.
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: formatting doctoc help
