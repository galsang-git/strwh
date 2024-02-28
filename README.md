# strwh
 Measure the width of a string
# install
## linux

## Windows
library(devtools)
devtools::install_local("strwh-2.0.0.zip")
library("strwh")

# example
```
library(strwh)
download_font()
tmp <- strwh_init()
strwh('ggplot2', s='Ahkhds', units="mm", family="serif", fontsize=100, fontface=1, tmp=tmp)
```
