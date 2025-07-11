install.packages("tesseract")
install.packages("webshot2")
install.packages("stringr")
# library(tesseract)
# library(webshot)
# webshot::install_phantomjs()
eng <- tesseract::tesseract("eng")
f_temp <- function(url) {
  webshot2::webshot(url = url, file = "Screenshot_tmp.png")
  img <- png::readPNG("Screenshot_tmp.png")
  png::writePNG(img[500:580,400:590,], "Screenshot_tmp_cut.png")
  text <- tesseract::ocr("Screenshot_tmp_cut.png", engine = eng)

  out <- as.numeric(substr(text, 1, regexpr("\\.", text)[[1]] + 1))

  if (is.na(out)){
    png::writePNG(img[500:580,490:540,], "Screenshot_tmp_pt1.png")
    text_pt1 <- tesseract::ocr("Screenshot_tmp_pt1.png", engine = eng)
    png::writePNG(img[500:580,540:560,], "Screenshot_tmp_pt2.png")
    text_pt2 <- tesseract::ocr("Screenshot_tmp_pt2.png", engine = eng)
    png::writePNG(img[500:580,563:584,], "Screenshot_tmp_pt3.png")
    text_pt3 <- tesseract::ocr("Screenshot_tmp_pt3.png", engine = eng)

    out <- as.numeric(paste0(substr(text_pt1, 1, 1),
                             substr(text_pt2, 1, 1),
                             ".",
                             substr(text_pt3, 1, 1)))
  }

  out
}

urls <- c(
  indoor = "https://deployment.egain.io/indoor/EGA94001446031B",
  outdoor = "https://deployment.egain.io/indoor/EGA94005487031B"
)


l_temps <- sapply(urls, f_temp)

if (is.na(l_temps["indoor"])){
  l_temps["indoor"] <- f_temp(urls["indoor"])
}
if (is.na(l_temps["indoor"])){
  l_temps["indoor"] <- f_temp(urls["indoor"])
}
if (is.na(l_temps["outdoor"])){
  l_temps["outdoor"] <- f_temp(urls["outdoor"])
}
if (is.na(l_temps["outdoor"])){
  l_temps["outdoor"] <- f_temp(urls["outdoor"])
}

d_temp <- data.frame(temp = l_temps)
d_temp$where <- rownames(d_temp)


# ------------------------------------------------------------------------------.

# url_out <- "https://www.tecson-data.ch/zurich/mythenquai/"
#
# temp_out <- readLines(url_out)
#
# temp_out <- temp_out[which(grepl(">Lufttemperatur</span>", temp_out)) + 6]
#
# temp_out <- substr(temp_out, regexpr("font-weight:bold;", temp_out) + 19,
#                    regexpr("font-weight:bold;", temp_out) + 23)
# temp_out <- stringr::str_extract_all(temp_out, "[0-9.,.-]+")[[1]]
# temp_out <- as.numeric(gsub(",", "\\.", temp_out))
#
# d_temp <- rbind(d_temp,
#       data.frame(temp = temp_out, room = "out"))
# https://opendata.swiss/de/dataset/messwerte-der-wetterstationen-der-wasserschutzpolizei-zurich2/resource/d3fecb83-9701-42e8-8b1c-1d9ad8523e06

# ------------------------------------------------------------------------------.

d_temp$time <- as.character(Sys.time())
rownames(d_temp) <- NULL

# ------------------------------------------------------------------------------.

if ("temp_data_inout.txt" %in% list.files("Output")) {
  write.table(d_temp[, c("time", "where", "temp")],
              col.names = F,
              file = "Output/temp_data_inout.txt",
              append = T, row.names = F)
} else {
  write.table(d_temp[, c("time", "where", "temp")],
              file = "Output/temp_data_inout.txt",
              row.names = F)
}
