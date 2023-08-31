#
# Basic Parameters
#
ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG BASE_REPO="arkcase/artifacts"
ARG BASE_VER="1.4.0"
ARG BASE_BLD="01"
ARG BASE_TAG="${BASE_VER}-${BASE_BLD}"

ARG ARKCASE_VER="2023.01.04"
ARG CONF_VER="${ARKCASE_VER}"
ARG PDFTRON_VER="9.3.0"
ARG EXT="core"

#
# The main WAR and CONF artifacts
#
ARG CONF_SRC="https://project.armedia.com/nexus/repository/arkcase/com/armedia/arkcase/arkcase-config-${EXT}/${CONF_VER}/arkcase-config-${EXT}-${CONF_VER}.zip"
ARG ARKCASE_SRC="https://project.armedia.com/nexus/repository/arkcase/com/armedia/acm/acm-standard-applications/arkcase/${ARKCASE_VER}/arkcase-${ARKCASE_VER}.war"

#
# The PDFNet library and binaries
#
ARG PDFTRON_SRC="https://project.armedia.com/nexus/repository/arkcase.release/com/armedia/arkcase/arkcase-pdftron-bin/${PDFTRON_VER}/arkcase-pdftron-bin-${PDFTRON_VER}.zip"

FROM "${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_TAG}"

#
# Basic Parameters
#

LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Development Team <devops@armedia.com>" \
      APP="ArkCase Development Deployer"

ENV ARKCASE_DIR="${FILE_DIR}/arkcase"
ENV ARKCASE_CONF_DIR="${ARKCASE_DIR}/conf"
ENV ARKCASE_WARS_DIR="${ARKCASE_DIR}/wars"

ENV PENTAHO_DIR="${FILE_DIR}/pentaho"

ENV SOLR_DIR="${FILE_DIR}/solr"

ENV ALFRESCO_DIR="${FILE_DIR}/alfresco"

ENV MINIO_DIR="${FILE_DIR}/minio"

#
# The ArkCase WAR file
#
ARG ARKCASE_VER
ARG ARKCASE_SRC
ENV ARKCASE_TGT="${ARKCASE_WARS_DIR}/arkcase.war"

#
# The contents of .arkcase
#
ARG CONF_VER
ARG CONF_SRC
ENV CONF_TGT="${ARKCASE_CONF_DIR}/00-conf.zip"

#
# PDFTron stuff for .arkcase (we always download this, just in case)
#
ARG PDFTRON_VER
ARG PDFTRON_SRC
ENV PDFTRON_TGT="${ARKCASE_CONF_DIR}/00-pdftron.zip"
RUN prep-artifact "${PDFTRON_SRC}" "${PDFTRON_TGT}" "${PDFTRON_VER}"

#
# Add the local files we want in this deployment
#
ADD file "${FILE_DIR}"

#
# Pull the base artifacts as required
#
RUN set -euo pipefail ; \
    if [ ! -f "${CONF_TGT}" ] ; then prep-artifact "${CONF_SRC}" "${CONF_TGT}" "${CONF_VER}" ; fi ; \
    if [ ! -f "${ARKCASE_TGT}" ] ; then prep-artifact "${ARKCASE_SRC}" "${ARKCASE_TGT}" "${ARKCASE_VER}" ; fi ;

#
# The last command, to make sure everything is kosher
#
RUN rebuild-helpers
