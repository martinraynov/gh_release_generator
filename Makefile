M = $(shell printf "\033[34;1m▶\033[0m")

######################
### MAIN FUNCTIONS ###
######################

.PHONY: release_push_github
release_push_github: ## Creating a new tag and release on github
ifndef REPOSITORY_URL
	$(error REPOSITORY_URL is not set !(Use "export REPOSITORY_URL=...") )
endif
ifndef VERSION
	$(error VERSION is not set !(Use "export VERSION=...") )
endif
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is not set !(Use "export GITHUB_TOKEN=...") )
endif

	$(info $(M) Create new tag and release for github : Repository : $(REPOSITORY_URL) , Version $(VERSION))

	VERSION="$(VERSION)" GITHUB_TOKEN="$(GITHUB_TOKEN)" ./build_github_release.sh

	@echo "Completed"

.PHONY: help
help: ## Prints this help message
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
