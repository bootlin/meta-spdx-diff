SUMMARY = "SPDX document comparison tool"
DESCRIPTION = "Compare SPDX 3.0 JSON documents to track changes in packages, \
kernel configuration, and PACKAGECONFIG settings between builds."
HOMEPAGE = "https://github.com/bootlin/sbom-diff"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a0a1050a465f5d6ca944306c5642dc96"

PYPI_PACKAGE = "sbom-diff"

inherit pypi python_setuptools_build_meta

SRC_URI[sha256sum] = "6ff16ec4793a5fed1b5bd5dea7ce149f1e7e4542b209fc677b680fa89af2851d"

RDEPENDS:${PN} = "python3-core"

BBCLASSEXTEND = "native nativesdk"
