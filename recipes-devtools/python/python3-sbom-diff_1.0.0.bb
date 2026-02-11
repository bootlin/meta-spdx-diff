SUMMARY = "SPDX document comparison tool"
DESCRIPTION = "Compare SPDX 3.0 JSON documents to track changes in packages, \
kernel configuration, and PACKAGECONFIG settings between builds."
HOMEPAGE = "https://github.com/bootlin/sbom-diff"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4a8425a3470f4570828f7d270eca516e"

SRC_URI = " \
    git://git@github.com/bootlin/sbom-diff.git;protocol=ssh;branch=main \
"

S = "${WORKDIR}/git"
SRCREV = "75c6923e4327d7945ca64da3ec4907d9ae8e56ae"

inherit python_hatchling

RDEPENDS:${PN} = "python3-core"

BBCLASSEXTEND = "native nativesdk"
