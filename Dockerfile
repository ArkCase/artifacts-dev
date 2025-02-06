#
# Basic Definitions
#
ARG EXT="core"
ARG VER="24.09.00"

#
# Basic Parameters
#
ARG BASE_REGISTRY="${PRIVATE_REGISTRY}"
ARG BASE_REPO="arkcase/artifacts-${EXT}"
ARG BASE_VER="${VER}"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

FROM "${BASE_IMG}"

#
# Basic Parameters
#
LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Development Team <devops@armedia.com>" \
      APP="ArkCase Development Deployer" \
      VER="${VER}" \
      EXT="${EXT}"

#
# Add the local files we want in this deployment
#
ADD file "${FILE_DIR}"

#
# The last command, to make sure everything is kosher
#
RUN rebuild-helpers
