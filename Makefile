M = $(shell printf "\033[34;1m▶\033[0m")

######################
### MAIN FUNCTIONS ###
######################

.PHONY: release_push_github
release_push_github: ## Creating a new tag and release on github
ifndef REPOSITORY
	$(error REPOSITORY is not set !(Use "export REPOSITORY=..."). You must specify the repository/app path (Ex: martinraynov/gh_release_generator).)
endif
ifndef VERSION
	$(error VERSION is not set !(Use "export VERSION=..."). You must specify the version of the release you are creating.)
endif
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is not set !(Use "export GITHUB_TOKEN=..."). You must specifiy the access_token to your repo.)
endif

	$(info $(M) Create new tag and release for github : Repository : $(REPOSITORY) , Version $(VERSION))

	VERSION="$(VERSION)" GITHUB_TOKEN="$(GITHUB_TOKEN)" ./build_github_release.sh

	@echo "Completed"

.PHONY: help
help: ## Prints this help message
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
