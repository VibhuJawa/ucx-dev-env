repos:
	git clone https://github.com/openucx/ucx && \
	git clone https://github.com/Akshay-Venkatesh/ucx-py && \
	git clone https://github.com/dask/distributed && \
	pushd distributed && \
	git remote rename origin upstream && \
	git remote add origin https://github.com/TomAugspurger/distributed && \
	popd
	pushd ucx-py && \
	git remote rename origin upstream && \
	git remote add origin https://github.com/TomAugspurger/ucx-py && \
	popd

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


