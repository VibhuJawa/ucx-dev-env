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
	git fetch origin && git checkout ucx && \
	cd ..
	cd ucx-py && \
	git remote rename origin upstream && \
	git remote add origin https://github.com/TomAugspurger/ucx-py && git fetch origin && git checkout data-handling && \
	cd ..


env:
	conda create -n ucx-dev-2 -c defaults -c conda-forge -c rapidsai -y python=3.7 ipython Cython pytest tornado numpy pandas pytest-asyncio numba

deps:
	# make sure to activate first
	cd dask && pip install -e . && cd ..
	cd distributed && pip install -r dev-requirements.txt && pip install -e .
	pip install --pre cupy-cuda92

# Notes: working at 7568aec, failing on master.
#   CXXLD    gtest
#   /usr/bin/ld: uct/ib/gtest-test_ib.o: undefined reference to symbol 'ibv_free_device_list@@IBVERBS_1.1'
#   //usr/lib/libibverbs.so.1: error adding symbols: DSO missing from command line
#   collect2: error: ld returned 1 exit status
#
# failing commit is c790d130411737c3b6719e100669b650248cf34f
#
ucx/install: ucx
	cd ucx && \
	git checkout c790d130411737c3b6719e100669b650248cf34f~1 && \
	./autogen.sh && \
	./configure --prefix="$$(pwd)/install" --enable-debug --disable-cma --enable-gtest --enable-logging --with-cuda=/usr/local/cuda --enable-profiling --enable-frame-pointer --enable-stats --enable-memtrack --enable-fault-injection --enable-debug-data --enable-mt && \
	$(MAKE) -j 8 install && \
  cd ..


build: ucx-py
	UCX_PREFIX="$$(pwd)/ucx/install" \
	CUDA_PREFIX="/usr/local/cuda-9.2" \
	LD_LIBRARY_PATH="$$(pwd)/ucx/install/lib":/usr/local/cuda/lib64:$LD_LIBRARY_PATH \
	CPATH="$$(pwd)/ucx/install/include":/usr/local/cuda/include:$CPATH \
	UCX_PY_CUDA_PATH=/usr/local/cuda/ \
	UCX_PY_UCX_PATH="$$(pwd)/ucx/install" \
	cd ucx-py && make install
