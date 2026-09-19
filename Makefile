.PHONY: watch, thesis, cover, install, docs, docs-serve, uv, uninstall-uv, clean, clean-all

IN?=
OUT?=

PDF_STANDARD?=a-2a#,ua-1

watch:
	mkdir -p $(dir $(if $(OUT),$(OUT),dist/))
	typst watch thesis.typ $(if $(OUT),$(OUT),dist/thesis.pdf) --open

thesis:
	mkdir -p $(dir $(if $(OUT),$(OUT),dist/))
	typst compile --pdf-standard $(PDF_STANDARD) $(if $(IN),$(IN),thesis.typ) $(if $(OUT),$(OUT),dist/thesis.pdf)
	qpdf --linearize --replace-input $(if $(OUT),$(OUT),dist/thesis.pdf) || true

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
	rm -rf dist docs/site

clean-all:
	rm -rf .venv

