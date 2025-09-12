.PHONY: help install deps lint check run debug clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

deps: ## Install Ansible dependencies
	ansible-galaxy collection install -r requirements.yml --force

lint: ## Run linters
	yamllint .
	ansible-lint

check: ## Check playbook syntax
	ansible-playbook site.yml --syntax-check

run: deps ## Run the playbook
	ansible-playbook site.yml

debug: ## Run playbook in verbose mode
	ansible-playbook site.yml -vvv

dry-run: ## Run playbook in check mode (no changes)
	ansible-playbook site.yml --check --diff

clean: ## Clean cache and temp files
	rm -rf /tmp/ansible_facts_cache
	find . -type f -name "*.retry" -delete