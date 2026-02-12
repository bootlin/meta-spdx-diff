SUMMARY = "SPDX document comparison tool"
DESCRIPTION = "Compare SPDX 3.0 JSON documents to track changes in packages, \
kernel configuration, and PACKAGECONFIG settings between builds."
HOMEPAGE = "https://github.com/bootlin/spdx-diff"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4a8425a3470f4570828f7d270eca516e"

PYPI_PACKAGE = "spdx_diff"

inherit pypi python_hatchling

SRC_URI[sha256sum] = "f9e53f50d16f3f2c3366ad3bc499dd95a6a805da845be3b8214c0234267c51f2"

RDEPENDS:${PN} = "python3-core"

BBCLASSEXTEND = "native nativesdk"
