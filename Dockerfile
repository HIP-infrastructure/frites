ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/jupyterlab-desktop:${JUPYTERLAB_DESKTOP_VERSION}${TAG}
LABEL maintainer="florian.sipp@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

ENV PATH="/apps/jupyterlab-desktop/conda/bin:${PATH}"

RUN mamba create -y --override-channels --channel=conda-forge --name=frites_env \
    # if we do not install those three, kernel is put in default jlab_env instead of frites_env \
    'pip' 'nb_conda_kernels' 'ipykernel' \
    # frites dependencies \
    'mne' 'numpy' 'scipy' 'xarray' 'dask' 'netCDF4' 'bottleneck' \
    'joblib' 'numba' 'matplotlib' 'seaborn' 'networkx' \
    && /apps/jupyterlab-desktop/conda/envs/frites_env/bin/pip install -U frites==${APP_VERSION}

ENV APP_SPECIAL="jupyterlab-desktop"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=".jupyter"
#ENV APP_DATA_DIR_ARRAY=".jupyter .config/jupyterlab-desktop"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
