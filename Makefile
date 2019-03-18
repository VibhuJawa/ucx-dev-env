# TODO: CUDA_PATH / CUDA_PREFIX
CUDA_PATH ?= "/usr/local/cuda"
CONDA_ROOT=dirname `dirname $CONDA_EXE`
# CFLAGS  = "-I${CONDA_PREFIX}/include -I$(CUDA_PATH)/include"
# LDFLAGS = "-L${CONDA_PREFIX}/lib -L$(CUDA_PATH)/lib64"


repos:
	git clone https://github.com/dask/dask && \
	git clone https://github.com/openucx/ucx && \
	git clone https://github.com/Akshay-Venkatesh/ucx-py && \
	git clone https://github.com/dask/distributed && \
	cd distributed && \
	git remote rename origin upstream && \
	git remote add origin https://github.com/TomAugspurger/distributed && \
	git fetch origin && git checkout ucx && \
	cd .. && \
	cd ucx-py && \
	git remote rename origin upstream && \
	git remote add origin https://github.com/TomAugspurger/ucx-py && \
	cd ..


env:
	conda env create -f environment-dev.yaml

deps:
	# make sure to activate first
	cd dask        && conda uninstall -y --force dask        || true && pip install --no-deps -e .
	cd distributed && conda uninstall -y --force distributed || true && pip install --no-deps -e .
	pip install pytest-asyncio --pre cupy-cuda92


# Pinned at ucx 1.5.0 for now
# Follow https://github.com/openucx/ucx/issues/3319 for blockers.
# The sed stuff is working around an issue with the generated Makefile

ucx/install: ucx
	cd ucx && \
	./autogen.sh && \
	./configure --prefix=${CONDA_PREFIX} \
		--disable-cma \
		--disable-numa \
		--enable-mt \
		--with-cuda=${CUDA_PREFIX} && \
	sed -i.bak "s,^CUDA_LDFLAGS.*,CUDA_LDFLAGS = -lcudart -lcuda -L${CUDA_PREFIX}/lib64," src/ucs/Makefile && \
	sed -i.bak "s,^LDFLAGS.*,LDFLAGS = -lcudart -lcuda -L${CUDA_PREFIX}/lib64," src/ucs/Makefile && \
	$(MAKE) -j 8 install && \
  cd ..


build: ucx-py
	cd ucx-py && \
	$(MAKE) install

# build: ucx-py
# 	CUDA_PREFIX="/usr/local/cuda-9.2" \
# 	LDFLAGS="$$-L(pwd)/ucx/install/lib -L${CUDA_PREFIX}/lib64 ${LDFLAGS}" \
# 	LD_LIBRARY_PATH="$$(pwd)/ucx/install/lib":${CUDA_PREFIX}/lib64:$LD_LIBRARY_PATH \
# 	CPATH="$$(pwd)/ucx/install/include":${CUDA_PREFIX}:include:$CPATH \
# 	UCX_PY_CUDA_PATH=${CUDA_PREFIX} \
# 	UCX_PY_UCX_PATH="$$(pwd)/ucx/install" \
# 	cd ucx-py && make install
