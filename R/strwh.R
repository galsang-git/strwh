#' @title Get the path of this script
#' @return a string, str, the path of this script
#' @importFrom rstudioapi getSourceEditorContext
#' @importFrom this.path this.path
#' @export
thisPath <- function(){
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

#' @title Download font files
#' @export
#' @importFrom utils download.file
#' @importFrom utils unzip
download_font <- function(fonts=NULL){
  if(is.null(fonts)){
    download.file("https://github.com/galsang-git/fonts/archive/refs/heads/master.zip",
                destfile = "fonts.zip" , mode='wb')
    fonts <- "fonts.zip"
  }
  unzip(fonts, exdir = paste0(.libPaths()[1], "/strwh"))
  file.remove("fonts.zip")
}

#' @title Load python in use_python
#' @param python_path str, a path of python.
#' @param fonts_path str, path of fonts
#' @param FontFileType str, ttf or afm
#' @return a class
#' @export
#' @importFrom reticulate source_python
#' @importFrom reticulate use_python
#' @importFrom reticulate py_available
strwh_init <- function(work_path=NULL, python_path=NULL, fonts_path=NULL, FontFileType='ttf'){

  #fontface: A numeric value in the range 0-1000 or one of 'ultralight',
  # 'light', 'normal', 'regular', 'book', 'medium', 'roman', 'semibold',
  # 'demibold', 'demi', 'bold', 'heavy', 'extra bold', 'black'.
  # Default: font.weight

  #1.setting python
  #use_condaenv("C:/Users/xyf/.conda/envs/python3_8")

  if(is.null(python_path)){
    python_path <- Sys.which('python')
  }
  use_python(python_path)

  if(py_available(TRUE)){
    print(paste0("python path: ", python_path))
  }

  #1.load python function
  if(is.null(work_path)){
    work_path <- paste0(.libPaths()[1], "/strwh")
  }
  if(!dir.exists(work_path)){
    stop("No such file or folder: ", work_path)
  }
  source_python(paste0(work_path, "/exec/functions.py"))

  #4.Measure text's width
  if(is.null(fonts_path)){
    if(FontFileType == 'ttf' & dir.exists(paste0(work_path, "/fonts/ttf"))){
      fonts_path <- paste0(work_path, "/fonts/ttf")
    }
    if(FontFileType == 'afm' & dir.exists(paste0(work_path, "/fonts/afm"))){
      fonts_path <- paste0(work_path, "/fonts/afm")
    }
    if(dir.exists("C:/Windows/Fonts")){
      fonts_path <- "C:/Windows/Fonts"
    }
    if(dir.exists("/usr/share/fonts/dejavu")){
      fonts_path <- "/usr/share/fonts/dejavu"
    }
  }

  tmp <- pill_strwh_addFonts(fonts_path=fonts_path, FontFileType=FontFileType)

  return(tmp)
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
#' @param tmp class
#' @return a width of font, float,
#' @export
#' @importFrom grid is.grob
#' @importFrom ggplot2 is.ggplot
#' @importFrom utils read.table
#' @importFrom reticulate source_python
strwh <- function(p, s='Ahkhds', units="mm", family="serif", fontsize=100, fontface=1,
                  familynames=NULL, work_path=NULL, tmp){

  #fontface: A numeric value in the range 0-1000 or one of 'ultralight',
  # 'light', 'normal', 'regular', 'book', 'medium', 'roman', 'semibold',
  # 'demibold', 'demi', 'bold', 'heavy', 'extra bold', 'black'.
  # Default: font.weight

  #1.load python function
  if(is.null(work_path)){
    work_path <- paste0(.libPaths()[1], "/strwh")
  }
  if(!dir.exists(work_path)){
    stop("No such file or folder: ", work_path)
  }
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
  if(is.null(familynames)){
    familynames = paste0(work_path, "/data/familynames.csv")
  }
  familynames_df <- read.table(familynames, sep=";", header = TRUE, as.is=FALSE)
  family_pil <- familynames_df[familynames_df$R == family, 'PIL']

  #4.Measure text's width
  width <- pill_strwh_measure(s, family=family_pil, fontface=fontface, size=pt,
                              tmp=tmp)

  if(units == "mm"){
    width <- width/(72/25.4)
  }else if(units == "inches"){
    width <- width/72
  }
  return(width)
}

