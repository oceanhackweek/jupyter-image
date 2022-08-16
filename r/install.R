# Install one or more R packages using remotes package
#
# Input/Output:
# @param single argument with fully qualified name to (yaml) configuration file
# @return 0 for success, non-zero if an issue arises.  Fails soon.
#
# Usage:
# Rscript /path/to/install.R /path/to/remotes.yml
#
library(yaml)
library(remotes)

x <- yaml::read_yaml(commandArgs(trailingOnly = TRUE)[1])

args <- x$extra

if ('install_cran' %in% names(x)){
  for (p in x[['install_cran']]){
    ok <- try(remotes::install_cran(p,
                                    dependencies=args$dependencies, 
                                    upgrade_dependencies=args$upgrade_dependencies, 
                                    upgrade=args$upgrade))
    if (inherits(ok, 'try-error')){
      print("unable to install package:", p)
      print(ok)
      quit(save = "no", status = 1)
    }
  }
}

if ('install_github' %in% names(x)){
  for (p in x[['install_github']]){
    ok <- try(remotes::install_github(p,
                                    dependencies=args$dependencies, 
                                    upgrade_dependencies=args$upgrade_dependencies, 
                                    upgrade=args$upgrade))
    if (inherits(ok, 'try-error')){

      print(ok)
      quit(save = "no", status = 1)
    }
  }
}

quit(save = "no", status = 0)