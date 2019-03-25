# TODO: add python
# Right now, using the libffi from the system
# https://devguide.python.org/setup/#build-dependencies
# haven't gotten from-source libffi working yet (well, ctypes wasn't
# building, not sure if libffi or something else)
# - add PATH
#

CONDA_ROOT=dirname `dirname $CONDA_EXE`

#repos:
#	git clone https://github.com/dask/dask && \
#	git clone https://github.com/openucx/ucx && \
#	git clone https://github.com/Akshay-Venkatesh/ucx-py && \
#	git clone https://github.com/dask/distributed && \
#	cd distributed && \
#	git remote rename origin upstream && \
#	git remote add origin https://github.com/TomAugspurger/distributed && \
#	git fetch origin && git checkout ucx && \
#	cd .. && \
#	cd ucx-py && \
#	git remote rename origin upstream && \
#	git remote add origin https://github.com/TomAugspurger/ucx-py && \
#	cd ..
	
repos:
	git clone https://github.com/dask/dask && \
	git clone https://github.com/openucx/ucx && \
	git clone https://github.com/dask/distributed && \
	cd distributed && \
	cd .. && \
	cd ucx-py && \
	cd ..


env:
	conda create -n ucx-dev -y python=3.7 \
		ipython Cython pytest tornado numpy pandas numba

deps:
	# make sure to activate first
	cd dask && pip install -e . && cd ..
	cd distributed && pip install -r dev-requirements.txt && pip install -e .
	pip install pytest-asyncio --pre cupy-cuda92


# Pinned at ucx 1.5.0 for now
# Follow https://github.com/openucx/ucx/issues/3319 for blockers.

ucx/install: ucx
	cd ucx && \
	./autogen.sh && \
	git checkout v1.5.0 && \
	./configure --prefix="$$(pwd)/install" \
		--disable-cma \
		--disable-numa \
		--enable-mt \
		--with-cuda=${CUDA_PREFIX} && \
	$(MAKE) -j 8 install && \
  cd ..


build: ucx-py
	UCX_PREFIX="$$(pwd)/ucx/install" \
	CUDA_PREFIX="/usr/local/cuda-9.2" \
	LDFLAGS="$$-L(pwd)/ucx/install/lib -L${CUDA_PREFIX}/lib64 ${LDFLAGS}" \
	LD_LIBRARY_PATH="$$(pwd)/ucx/install/lib":${CUDA_PREFIX}/lib64:$LD_LIBRARY_PATH \
	CPATH="$$(pwd)/ucx/install/include":${CUDA_PREFIX}:include:$CPATH \
	UCX_PY_CUDA_PATH=${CUDA_PREFIX} \
	UCX_PY_UCX_PATH="$$(pwd)/ucx/install" \
	cd ucx-py && make install
