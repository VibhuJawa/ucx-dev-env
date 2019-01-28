# TODO: add python
# Right now, using the libffi from the system
# https://devguide.python.org/setup/#build-dependencies
# haven't gotten from-source libffi working yet (well, ctypes wasn't
# building, not sure if libffi or something else)
# - add PATH
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
	git remote add origin https://github.com/TomAugspurger/ucx-py && \
	cd ..


Python-3.7.2:
	wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz
	tar zxf Python-3.7.2.tgz


Envs/python-3.7.2: Python-3.7.2
	cd Python-3.7.2 && \
		./configure && \
        make -j 8 && \
		mkdir -p ../Envs && \
		./python -m venv ../Envs/python-3.7.2

deps:
	# make sure to activate first
	cd dask && pip install -e . && cd ..
	cd distributed && pip install -r dev-requirements.txt && pip install -e .
	pip install ipython Cython

ucx/install: ucx
	cd ucx && \
	./autogen.sh && \
	./configure --prefix="$$(pwd)/install" --enable-debug --disable-cma --enable-gtest --enable-logging --with-cuda=/usr/local/cuda --with-gdrcopy=/usr --enable-profiling --enable-frame-pointer --enable-stats --enable-memtrack --enable-fault-injection --enable-debug-data --enable-mt && \
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


