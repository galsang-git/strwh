#' @title Load python in use_python
#' @param python_path str, a path of python.
#' @return nothing
#' @export
#' @importFrom reticulate py_available
#' @importFrom reticulate use_python
strwh_init <- function(python_path="python"){
  #1.setting python
  #use_condaenv("C:/Users/xyf/.conda/envs/python3_8")

  if(python_path == "python"){
    python_path <- Sys.which('python')
  }
  use_python(python_path)
  if(py_available(TRUE)){
    print(paste0("python path: ", python_path))
  }
}

#' Get the path of this script
#'
#' @return a string, str, the path of this script
#' @importFrom rstudioapi getSourceEditorContext
#' @importFrom this.path this.path

#' @export
thisPath <- function() {
  cmdArgs <- commandArgs(trailingOnly = FALSE)
  if (length(grep("^-f$", cmdArgs)) > 0) {    # R console option
    scriptPath <- normalizePath(dirname(cmdArgs[grep("^-f", cmdArgs) + 1]))[1]
  } else if (length(grep("^--file=", cmdArgs)) > 0) {    # Rscript/R console option
    scriptPath <- normalizePath(dirname(sub("^--file=", "", cmdArgs[grep("^--file=", cmdArgs)])))[1]
  } else if (this.path()) {    # RStudio
    scriptPath <- dirname(this.path())
  }else if (Sys.getenv("RSTUDIO") == "1") {    # RStudio
    scriptPath <- dirname(getSourceEditorContext()$path)
  } else {    stop("Cannot find file path")
  }
  return(scriptPath)
}


#' Title
#'
#' @param p str, "ggplot2" or "grib"
#' @param s str, a measured text
#' @param units str, "mm"
#' @param family str, "serif"
#' @param fontsize int, fontsize in ggplot2
#' @param fontface int, fontface in 1,2,3,4
#' @param familynames str, data/familynames.csv
#' @param fonts_path str, path of fonts
#' @return a width of font, float,
#' @export
#' @importFrom grid is.grob
#' @importFrom ggplot2 is.ggplot
#' @importFrom utils read.table
#' @importFrom reticulate source_python
strwh <- function(p, s='A', units="mm", family="serif", fontsize=100, fontface=1,
                  familynames=NULL, fonts_path=NULL){

  #fontface: A numeric value in the range 0-1000 or one of 'ultralight',
  # 'light', 'normal', 'regular', 'book', 'medium', 'roman', 'semibold',
  # 'demibold', 'demi', 'bold', 'heavy', 'extra bold', 'black'.
  # Default: font.weight

  #1.load python function
  work_path <<- paste0(.libPaths()[1], "/strwh")
  source_python(paste0(work_path, "/exec/functions.py"))

  if(is.ggplot(p)){
    bool_plot <- "ggplot2"
  }else if(is.grob(p)){
    bool_plot <- "grid"
  }else if(is.character(p)){
    bool_plot <- p
  }else{
    bool_plot <- ""
  }

  #2.Convert text size
  if(bool_plot == "ggplot2"){
    pt <- round(fontsize*ggplot2::.pt, 0)
  }else if(bool_plot == "grid"|bool_plot == "gpar"){
    pt <- round(fontsize, 0)
  }else{
    print("\"p\" is not recognized as ggplot2 or grob.")
    return(NA)
  }

  if(fontface %in% c(1, "regular", "plain")){
    fontface = 1
  }else if(fontface %in% c(2, "bold")){
    fontface = 2
  }else if(fontface %in% c(3, "italic")){
    fontface = 3
  }else if(fontface %in% c(4, "bold.italic")){
    fontface = 4
  }
  #3.Convert font
  if(!familynames){
    familynames = paste0(work_path, "/../data/familynames.csv")
  }
  familynames_df <- read.table(familynames, sep=";", header = TRUE, as.is=FALSE)
  family_pil <- familynames_df[familynames_df$R == family, 'PIL']

  #4.Measure text's width
  if(!fonts_path){
    fonts_path <- "C:/Windows/Fonts"
  }
  width <- pill_strwh(s, family=family_pil, fontface=fontface, size=pt,
                      fonts_path=fonts_path)
  if(units == "mm"){
    width <- width/(72/25.4)
  }else if(units == "inches"){
    width <- width/72
  }
  return(width)
}

