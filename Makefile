.PHONY: watch, thesis, cover, clean, clean-all

IN?=
OUT?=

PDF_STANDARD?=a-2a#,ua-1

watch:
	mkdir -p $(dir $(if $(OUT),$(OUT),.))
	typst watch thesis.typ $(if $(OUT),$(OUT),thesis.pdf) --open

thesis:
	mkdir -p $(dir $(if $(OUT),$(OUT),.))
	typst compile --pdf-standard $(PDF_STANDARD) $(if $(IN),$(IN),thesis.typ) $(if $(OUT),$(OUT),thesis.pdf)
	qpdf --linearize --replace-input $(if $(OUT),$(OUT),thesis.pdf) || true

cover:
	mkdir -p $(dir $(if $(OUT),$(OUT),.))
	typst compile --pretty --pages 1 --ppi 250 --no-pdf-tags thesis.typ $(if $(OUT),$(OUT),cover.pdf)

clean:
clean-all:
