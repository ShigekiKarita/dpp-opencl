# OpenCL demo using dpp


## install requirements

First, install a suitable OpenCL driver of your GPU device. Then,
```bash
sudo apt-get install libclang-6.0-dev

source $(curl https://dlang.org/install.sh | bash -s -- ldc-1.18.0 -a)

dub fetch dpp --version=0.4.0
dub run dpp -- --help
```

## how to run

```bash
dub run --compiler=ldc2
```


## see also

https://github.com/atilaneves/dpp
