install.packages("tesseract")
install.packages("webshot")
# library(tesseract)
# library(webshot)
webshot::install_phantomjs()
eng <- tesseract::tesseract("eng")
f_temp <- function(url) {
  webshot::webshot(url = url, file = paste0("Screenshots/", url, "tmp.png"))
  img <- png::readPNG(paste0("Screenshots/", url, "tmp.png"))
  png::writePNG(img[450:550,780:860,], paste0("Screenshots/", url, "tmp.png"))
  text <- tesseract::ocr(paste0("Screenshots/", url, "tmp.png"), engine = eng)
  out <- as.numeric(substr(text, 1, regexpr("\\.", text)[[1]] + 1))

  if (is.na(out)){
    png::writePNG(img[450:550,780:814,], paste0("Screenshots/", url, "tmp_pt1.png"))
    text_pt1 <- tesseract::ocr(paste0("Screenshots/", url, "tmp_pt1.png"), engine = eng)
    png::writePNG(img[450:550,815:840,], paste0("Screenshots/", url, "tmp_pt2.png"))
    text_pt2 <- tesseract::ocr(paste0("Screenshots/", url, "tmp_pt2.png"), engine = eng)
    png::writePNG(img[450:550,840:860,], paste0("Screenshots/", url, "tmp_pt3.png"))
    text_pt3 <- tesseract::ocr(paste0("Screenshots/", url, "tmp_pt3.png"), engine = eng)

    out <- as.numeric(paste0(substr(text_pt1, 1, 1),
                             substr(text_pt2, 1, 1),
                             ".",
                             substr(text_pt3, 1, 1)))
  }

  out
}

urls <- c(
  room0 = "https://deployment.egain.io/indoor/EGA94001446031B",
  room1 = "https://deployment.egain.io/indoor/EGA94006601031B",
  room2 = "https://deployment.egain.io/indoor/EGA94006329031B",
  room3 = "https://deployment.egain.io/indoor/EGA94005487031B",
  room4 = "https://deployment.egain.io/indoor/EGA94000446031B",
  room5 = "https://deployment.egain.io/indoor/EGA94003678031B",
  room6 = "https://deployment.egain.io/indoor/EGA94003565031B",
  room7 = "https://deployment.egain.io/indoor/EGA94003382031B",
  room8 = "https://deployment.egain.io/indoor/EGA94003212031B",
  room9 = "https://deployment.egain.io/indoor/EGA94002076031B"
)


l_temps <- sapply(urls, f_temp)

d_temp <- data.frame(temp = l_temps)
d_temp$room <- rownames(d_temp)
d_temp$time <- as.character(Sys.time())
rownames(d_temp) <- NULL

if ("temp_data.txt" %in% list.files("Output")) {
  write.table(d_temp[, c("time", "room", "temp")],
              col.names = F,
              file = "Output/temp_data.txt",
              append = T, row.names = F)
} else {
  write.table(d_temp[, c("time", "room", "temp")],
              file = "Output/temp_data.txt",
              row.names = F)
}
