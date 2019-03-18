Setup a dev environment

Manually set

1. `CUDA_PREFIX` in `activate_`


Run the following


```
make repos
make env
. activate_
make deps
make ucx/install
make build
```

Verify the ucx-py install with

```
$ cd ucx-py
$ python -m pytest tests
```

Verify the distributed isntall with


```
python -m pytest distributed/comm/tests/test_ucx.py
```


Conda-based has a few changes

1. Assumes installing ucx in `$CONDA_PREFIX` to make discovery of the
   libs / headers easier for ucx-py
2. Patches UCX 1.5's `--with-cuda` autotools stuff (ugly sed scripts)
   UCX master doesn't have this issue, but it needs to be tested (we opened
   an issue that has been fixed, but untested).

* Manually install dask-cudf
* Apply ucx-py-make-diff.diff
* Clone TomAugspurger/dask-perf
* Use environment-dev.yaml, not environment.yaml

