# TODO: add python
# Right now, using the libffi from the system
# https://devguide.python.org/setup/#build-dependencies
# haven't gotten from-source libffi working yet (well, ctypes wasn't
# building, not sure if libffi or something else)
# - add PATH
#

CONDA_ROOT=dirname `dirname $CONDA_EXE`

repos:
	git clone https://github.com/dask/dask && \
	git clone https://github.com/openucx/ucx && \
	git clone https://github.com/Akshay-Venkatesh/ucx-py && \
	git clone https://github.com/dask/distributed && \
	cd distributed && \
	git remote rename origin upstream && \
	git remote add origin https://github.com/TomAugspurger/distributed && \
	git fetch origin && git checkout ucx+data-handling && \
	cd .. && \
	cd ucx-py && \
	git remote rename origin upstream && \
	git remote add origin https://github.com/TomAugspurger/ucx-py && \
	git fetch origin && git checkout data-handling && \
	cd ..


env:
	conda create -n ucx-dev -y python=3.7 \
		ipython Cython pytest tornado numpy pandas numba

deps:
	# make sure to activate first
	cd dask && pip install -e . && cd ..
	cd distributed && pip install -r dev-requirements.txt && pip install -e .
	pip install pytest-asyncio --pre cupy-cuda92

# Notes: working at 7568aec, failing on master.
#   CXXLD    gtest
#   /usr/bin/ld: uct/ib/gtest-test_ib.o: undefined reference to symbol 'ibv_free_device_list@@IBVERBS_1.1'
#   //usr/lib/libibverbs.so.1: error adding symbols: DSO missing from command line
#   collect2: error: ld returned 1 exit status
#
# failing commit is c790d130411737c3b6719e100669b650248cf34f
#                   c790d130411737c3b6719e100669b650248cf34f
#
#
# wget the patch until https://github.com/openucx/ucx/pull/3315 is merged

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
	LD_LIBRARY_PATH="$$(pwd)/ucx/install/lib":${CUDA_PREFIX}/lib64:$LD_LIBRARY_PATH \
	CPATH="$$(pwd)/ucx/install/include":${CUDA_PREFIX}:include:$CPATH \
	UCX_PY_CUDA_PATH=${CUDA_PREFIX} \
	UCX_PY_UCX_PATH="$$(pwd)/ucx/install" \
	cd ucx-py && git checkout data-handling && make install
