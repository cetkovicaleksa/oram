.DEFAULT_GOAL := help
.PHONY: help watch thesis cover install docs docs-serve uv uninstall-uv clean clean-all

IN?=
OUT?=

PDF_STANDARD?=a-2a#,ua-1

help:
	@printf "Available targets:\n"
	@printf "  help         Show this help message\n"
	@printf "  watch        Watch and rebuild the thesis\n"
	@printf "  thesis       Compile the thesis\n"
	@printf "  cover        Compile the cover page\n"
	@printf "  install      Install project and dependencies to a venv\n"
	@printf "  docs         Build the docs site\n"
	@printf "  docs-serve   Serve the docs locally\n"
	@printf "  uv           Install uv if missing\n"
	@printf "  uninstall-uv Remove uv installation and cache\n"
	@printf "  clean        Clean all artifacts\n"
	@printf "  clean-all    Clean all artifacts and uninstall project and dependencies\n"

watch:
	mkdir -p $(dir $(if $(OUT),$(OUT),dist/))
	typst watch thesis.typ $(if $(OUT),$(OUT),dist/thesis.pdf) --open

thesis:
	mkdir -p $(dir $(if $(OUT),$(OUT),dist/))
	typst compile --pdf-standard $(PDF_STANDARD) $(if $(IN),$(IN),thesis.typ) $(if $(OUT),$(OUT),dist/thesis.pdf)
	uv run scripts/layer_pdf.py $(if $(OUT),$(OUT),dist/thesis.pdf) || true
	qpdf --linearize --newline-before-endstream --replace-input $(if $(OUT),$(OUT),dist/thesis.pdf) || true

cover:
	mkdir -p $(dir $(if $(OUT),$(OUT),dist/))
	typst compile --pretty --pages 1 --ppi 250 --no-pdf-tags thesis.typ $(if $(OUT),$(OUT),dist/cover.pdf)

install:
	uv sync --dev

.PHONY: docs
docs:
	uv run --group docs mkdocs build --config-file docs/mkdocs.yml

docs-serve:
	uv run --group docs mkdocs serve --config-file docs/mkdocs.yml --open

uv:
	uv --version || curl -LsSf https://astral.sh/uv/install.sh | sh

uninstall-uv:
	uv cache clean
	rm -r "$(uv python dir)"
	rm -r "$(uv tool dir)"

clean:
	rm -rf dist build docs/site *.egg-info src/*.egg-info target
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*$$py.class" -delete

	rm -rf .pytest_cache .ruff_cache .mypy_cache .coverage htmlcov

clean-all: clean
	rm -rf .venv

