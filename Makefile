.DEFAULT_GOAL := all

.PHONY: all
all: ## Show the available make targets.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: clean
clean: ## Clean the temporary files.
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf .coverage
	rm -rf .ruff_cache
	rm -rf megalinter-reports
	rm -rf site

.PHONY: install
install:  ## Install the dependencies excluding dev.
	poetry install --only main

.PHONY: install-dev
install-dev:  ## Install the dependencies including dev.
	poetry install

.PHONY: install-docs
install-docs:  ## Install only the documentation dependencies
	poetry install --only docs

.PHONY: py_lint
py_lint:  ## Run all Python linters (black/ruff/pylint/mypy).
	poetry run black --check src
	poetry run ruff check src
	make mypy

.PHONY: py_fix
py_fix:  ## Format the Python code.
	poetry run black src
	poetry run ruff check src --fix

.PHONY: test
test:  ## Run the tests and check coverage.
	poetry run pytest -n auto --cov=src --cov-report term-missing --cov-fail-under=95

.PHONY: mypy
mypy:  ## Run mypy.
	poetry run mypy src

.PHONY: md_lint
md_lint: ## Lint Markdown files using Markdownlint.
	@echo "Running Markdownlint...";
	sh ./shell_scripts/linting/md_lint.sh

.PHONY: md_fix
md_fix: ## Fix Markdown files using Markdownlint.
	@echo "Running Markdownlint fix...";
	sh ./shell_scripts/linting/md_fix.sh

.PHONY: megalint
megalint:  ## Run the mega-linter.
	docker run --platform linux/amd64 --rm \
		-v /var/run/docker.sock:/var/run/docker.sock:rw \
		-v $(shell pwd):/tmp/lint:rw \
		oxsecurity/megalinter:v8