# HandleGraph paper

This paper describes a number of succinct, dynamic variation graph implementations and their common API and data model.

To build (on Ubuntu 20.04 or similar), you'll need texlive and its extras:

```
sudo apt install texlive texlive-latex-extra
```

Then `make` will build the paper `main.pdf` in the root directory.

## analysis

The repository includes results from computational experiments on a number of HandleGraph implementations.

There are a few analyses based based on linear regression that compare the different implementations.
A number of log/log scaled plots illustrate performance of the various methods for construction, loading, and graph iteration versus graph size.

To generate them, run:

```
cd analysis
./run.sh
```

The panels of figure 2 are among those that this script produces.
A final concatenated PDF includes both the regressions and the plots.
