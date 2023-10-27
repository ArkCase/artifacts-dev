#
# Basic Definitions
#
ARG EXT="core"
ARG VER="2023.01.06"

#
# Basic Parameters
#
ARG REG="public.ecr.aws"
ARG REP="arkcase/artifacts-${EXT}"
ARG BASE_IMAGE="${REG}/${REP}:${VER}"

FROM "${BASE_IMAGE}"

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
