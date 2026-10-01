# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pikepdf>=10.16.0",
# ]
# ///
"""Add optional layers to a Typst-generated PDF.

The added layers are ``Header``, ``Page Numbers``, and ``Form IDs``. Headers
are identified by Typst's tagged ``/Artifact`` pagination content with the
``/Header`` subtype. Footer content is split into graphics blocks: centered
blocks are assigned to ``Page Numbers`` and right-side blocks to ``Form IDs``
based on their horizontal transform position. Other footer content is left
unchanged.

Tested with Typst 0.15.0. This may be fragile because it relies on the
current marked-content structure and footer geometry produced by Typst.
Created with Claude, ChatGpt and GitHub Copilot.
"""


import os
import sys
import tempfile
from pathlib import Path

import pikepdf
from pikepdf import Array, Dictionary, Name, Operator


LAYER_DEFINITIONS = {
    "Header": "Headers",
    "PageNumbers": "Page Numbers",
    "FormId": "Form IDs",
}


def is_pagination_artifact(operands):
    return (
        len(operands) > 1
        and str(operands[0]) == "/Artifact"
        and isinstance(operands[1], pikepdf.Dictionary)
        and str(operands[1].get("/Type")) == "/Pagination"
        and str(operands[1].get("/Subtype")) in ("/Header", "/Footer")
    )


def marked_content_end(instructions, start):
    depth = 1
    for index in range(start + 1, len(instructions)):
        operation = str(instructions[index][1])
        if operation in ("BDC", "BMC"):
            depth += 1
        elif operation == "EMC":
            depth -= 1
            if depth == 0:
                return index
    raise ValueError("Unclosed pagination artifact")


def first_transform_x(block):
    for operands, operation in block:
        if str(operation) == "cm" and len(operands) >= 5:
            return float(operands[4])
    return None


def footer_layer_name(block, page_width):
    x = first_transform_x(block)
    if x is None:
        return None

    if page_width * 0.40 <= x <= page_width * 0.60:
        return "PageNumbers"
    if x >= page_width * 0.62:
        return "FormId"
    return None


def footer_blocks(body):
    blocks = []
    start = None
    depth = 0
    for index, (_, operation) in enumerate(body):
        operation = str(operation)
        if operation == "q":
            if depth == 0:
                start = index
            depth += 1
        elif operation == "Q" and depth:
            depth -= 1
            if depth == 0:
                blocks.append((start, index))
    return blocks


def optional_content_wrapper(property_name):
    return [
        ([Name.OC, Name("/" + property_name)], Operator("BDC")),
    ]


def wrap_footer(body, page_width):
    blocks = footer_blocks(body)
    if not blocks:
        return body

    out = []
    block_start = 0
    for start, end in blocks:
        out.extend(body[block_start:start])
        layer_name = footer_layer_name(body[start:end + 1], page_width)
        if layer_name is None:
            out.extend(body[start:end + 1])
        else:
            out.extend(optional_content_wrapper(layer_name))
            out.extend(body[start:end + 1])
            out.append(([], Operator("EMC")))
        block_start = end + 1
    out.extend(body[block_start:])
    return out


def wrap_pagination_artifacts(page, instructions):
    out = []
    index = 0
    page_width = float(page.MediaBox[2] - page.MediaBox[0])
    while index < len(instructions):
        operands, operation = instructions[index]
        if str(operation) != "BDC" or not is_pagination_artifact(operands):
            out.append((operands, operation))
            index += 1
            continue

        end = marked_content_end(instructions, index)
        subtype = str(operands[1].get("/Subtype"))
        body = instructions[index + 1:end]
        out.append((operands, operation))
        if subtype == "/Header":
            out.extend(optional_content_wrapper("Header"))
            out.extend(body)
            out.append(([], Operator("EMC")))
        else:
            out.extend(wrap_footer(body, page_width))
        out.append(instructions[end])
        index = end + 1
    return out

def layer_pdf(src, dst):
    destination = Path(dst).resolve()
    destination.parent.mkdir(parents=False, exist_ok=True)
    temporary_fd, temporary_name = tempfile.mkstemp(
        prefix=f".{destination.name}.",
        suffix=".tmp",
        dir=destination.parent,
    )
    os.close(temporary_fd)

    try:
        with pikepdf.open(src) as pdf:
            ocgs = {
                key: pdf.make_indirect(
                    Dictionary(
                        Type=Name.OCG,
                        Name=label,
                        Intent=Name.View,
                        Usage=Dictionary(
                            View=Dictionary(
                                ViewState=Name.ON,
                            ),
                            Print=Dictionary(
                                PrintState=Name.ON,
                            ),
                        ),
                    )
                )
                for key, label in LAYER_DEFINITIONS.items()
            }

            for page in pdf.pages:
                instrs = pikepdf.parse_content_stream(page)
                out = wrap_pagination_artifacts(page, instrs)
                page.Contents = pdf.make_stream(pikepdf.unparse_content_stream(out))
                res = page.Resources
                if "/Properties" not in res:
                    res.Properties = Dictionary()
                for key in ocgs:
                    res.Properties[Name("/" + key)] = ocgs[key]

            pdf.Root.OCProperties = Dictionary(
                OCGs=Array(list(ocgs.values())),
                D=Dictionary(
                    Name="Default",
                    BaseState=Name.ON,
                    Order=Array(list(ocgs.values())),
                ),
            )
            pdf.save(temporary_name)

        os.replace(temporary_name, destination)
    except BaseException:
        try:
            os.unlink(temporary_name)
        except FileNotFoundError:
            pass
        raise


arguments = sys.argv[1:]
if len(arguments) not in (1, 2):
    raise SystemExit(
        "usage: layer_pdf.py INPUT.pdf [OUTPUT.pdf]\n"
        "       omit OUTPUT.pdf to replace INPUT.pdf safely"
    )

src = arguments[0]
dst = arguments[1] if len(arguments) == 2 else src
layer_pdf(src, dst)
