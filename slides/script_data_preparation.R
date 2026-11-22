
# library -----------------------------------------------------------------

library(tidyverse)
library(here)

library(suwo)
library(tuneR)
library(seewave)

library(seewave)
library(birdnetR)
library(birdnetTools)


# part 1: query and download ----------------------------------------------

# query sounds from Xeno-Canto
amro <- query_xenocanto(species = "Turdus migratorius")

amro_canada <- query_xenocanto(species = 'sp: "Turdus migratorius" cnt:"canada"')

amro_vancouver <- query_xenocanto(species = 'sp: "Turdus migratorius" lat: "49.26" lon: "-123.11"')

# take a look
amro_vancouver |>
  head()

amro_vancouver[8,]



# download it (saved to "presentation slides/audio")
audio_dir <- here("presentation slides", "audio")
dir.create(audio_dir, showWarnings = FALSE)

set.seed(123)
download_media(metadata = amro_vancouver[8,],
               path = audio_dir)



# part 2: read and check --------------------------------------------------


# listen to it
file <- tibble(path = list.files(audio_dir, pattern = "\\.mp3$", full.names = TRUE)) |>
  mutate(modified = file.mtime(path)) |>
  slice_max(modified, n = 1) |>   # newest download
  pull(path)

play(readMP3(file))


# look at it
readMP3(file) |>
  mono() |>
  extractWave(from = 2, to = 11, xunit = "time") |>
  spectro(wl = 512, ovlp = 75, flim = c(0, 6),
          scale = FALSE,
          fastdisp = TRUE)


# part 3: identify with BirdNET -------------------------------------------

# check who is singing
model <- load_birdnet()

audio_path <- "C:/Users/sunny/Desktop/R ladies Vancouver talk/presentation slides/audio/Turdus_migratorius-XC465001.mp3"

predictions <- predict(model,
                       files = audio_path,
                       min_confidence = 0.3)

# who!?
as.data.frame(predictions) |>
  mutate(common_name = str_split_i(species_name, "_", 2)) |>
  select(start_time, end_time, common_name, confidence)




# play a game -------------------------------------------------------------

# local recordings
Merida_birds <- query_xenocanto(species = 'lat: "20.97" lon: "-89.61" type: "song" q:">C"')

Merida_birds |>
  pull(species) |>
  unique()


# pre download (saved to "presentation slides/audio_game")
audio_game_dir <- here("slides", "audio_game")
dir.create(audio_game_dir, showWarnings = FALSE)

# download_media(metadata = Merida_birds,
#                path = audio_game_dir)



# pre-processing of BirdNET

# done by GUI


# pre-create the spectrograms
audio_game_spectrogram_dir <- here("slides", "audio_game_spectrogram")
dir.create(audio_game_spectrogram_dir, showWarnings = FALSE)

for (i in 1:nrow(Merida_birds)) {

  audio_path_raw <- paste0(str_replace_all(Merida_birds[i,]$species, " ", "_"),
                           "-XC",
                           Merida_birds[i,]$key)

  audio_path <- paste0(audio_path_raw, ".", Merida_birds[i,]$file_extension)

  ext <- tolower(tools::file_ext(audio_path))

  if (ext == "mp3") {
    audio <- readMP3(paste0(audio_game_dir, "/", audio_path))
  } else if (ext == "wav") {
    audio <- readWave(paste0(audio_game_dir, "/", audio_path))
  }

  # highest usable frequency in kHz, and clip length in case it's under 10 s
  nyquist_khz <- audio@samp.rate / 2000
  dur <- length(audio@left) / audio@samp.rate

  png(paste0(audio_game_spectrogram_dir, "/", audio_path_raw, ".png"),
      width = 1600, height = 600, res = 150)

  audio |>
    extractWave(from = 0, to = min(10, dur), xunit = "time") |>
    spectro(flim = c(1, min(10, nyquist_khz)), fastdisp = TRUE, scale = FALSE)

  dev.off()
}





# others ------------------------------------------------------------------

# Player A (one person)
i <- 4 # anynumber between 1:nrow(vancouver_birds)

# Player B (group)

# construct the file name
path_raw <- paste0(str_replace_all(vancouver_birds_selected[i,]$species, " ", "_"),
                   "-XC", vancouver_birds_selected[i,]$key)


audio_path <- paste0(path_raw, ".", vancouver_birds_selected[i,]$file_extension)

image_path <- paste0(path_raw, ".png")


# read in the audio
ext <- tolower(tools::file_ext(audio_path))

if (ext == "mp3") {
  audio <- readMP3(here("presentation slides", "audio_game", audio_path))
} else if (ext == "wav") {
  audio <- readWave(here("presentation slides", "audio_game", audio_path))
}


# play
audio |>
  play()


# look




# answer by BirdNET
model <- load_birdnet()

predictions <- predict(model,
                       files = here("presentation slides", "audio_game", audio_path),
                       min_confidence = 0.3)

predictions_df <- predictions |>
  as.data.frame()

# did you get this one!


