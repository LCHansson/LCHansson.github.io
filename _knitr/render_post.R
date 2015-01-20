#!/usr/bin/env Rscript

input <- commandArgs(trailingOnly = TRUE)
KnitPost <- function(input, base.url = "/") {
    require(knitr)
    
    # Encoding and locale options
    # (we need this so Unicode characters in print() statements don't get weird)
    options(Encoding = "UTF-8")
    Sys.setlocale(category = "LC_ALL", locale = "sv_SE")
    
    # More knit options and tracking output
    opts_knit$set(base.url = base.url)
    opts_knit$set(width = 90)
    fig.path <- paste0("../fig/", sub(".Rmd$", "", basename(input)), "/")
    opts_chunk$set(fig.path = fig.path)
    opts_chunk$set(fig.cap = "center")
    opts_chunk$set(collapse=FALSE)
    opts_chunk$set(comment=">")
    render_jekyll(highlight = 'pygments')
    print(paste0("../_posts/", sub(".Rmd$", "", basename(input)), ".md"))
    
    # Knit
    knit(input,
         output = paste0("../_posts/", sub(".Rmd$", "", basename(input)), ".md"),
         envir = parent.frame(),
         encoding = "UTF-8")
}

KnitPost(input)
