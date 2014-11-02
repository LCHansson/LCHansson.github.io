#!/usr/bin/env Rscript

input <- commandArgs(trailingOnly = TRUE)
KnitPost <- function(input, base.url = "/") {
    require(knitr)
    opts_knit$set(base.url = base.url)
    fig.path <- paste0("../fig/", sub(".Rmd$", "", basename(input)), "/")
    opts_chunk$set(fig.path = fig.path)
    opts_chunk$set(fig.cap = "center")
    opts_chunk$set(collapse=TRUE)
    opts_chunk$set(comment=">")
    render_jekyll(highlight = 'pygments')
    print(paste0("../_posts/", sub(".Rmd$", "", basename(input)), ".md"))
    knit(input, output = paste0("../_posts/", sub(".Rmd$", "", basename(input)), ".md"), envir = parent.frame())
}

KnitPost(input)
