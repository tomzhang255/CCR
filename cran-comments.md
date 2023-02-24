## R CMD check results

There were no ERRORs, WARNINGs or NOTEs for macOS R-devel (2023/02/13, r83829).

There were no ERRORs or WARNINGs for Windows R-devel (2023-02-23 r83894 ucrt), only 1 NOTE:

```
* checking CRAN incoming feasibility ... [8s] NOTE
Maintainer: 'Tom Zhang <zhangsiyuan777@gmail.com>'

New submission

Version contains large components (0.0.0.9000)

Possibly misspelled words in DESCRIPTION:
  CCR (2:43, 6:38)
  DDR (6:99)
  NLP (6:148)
```

This note can be ignored because the "large components" are in fact `jpeg` example images in `man/figures/` which are used in `README.md` for illustration purposes. And the "misspelled words" in `DESCRIPTION`'s "Description" field are indeed correct acronyms.

## Downstream dependencies

There are currently no downstream dependencies for this package.
