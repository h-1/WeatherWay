# Libraries
# SVM
# install.packages("kernlab")
library(kernlab)

library(ggplot2)


# Remove all objects defined in workspace
rm(list = ls())

# set saving file path here
# save_path = "/resources/Pattern/"

# Load in data
weather_raw <- read.csv("/resources/all_traffic.csv", stringsAsFactors=FALSE)
weather_raw$fog <- factor(weather_raw$fog)
weather_raw$rain <- factor(weather_raw$rain, labels=c("No Rain", "Rain"))
weather_raw$snow <- factor(weather_raw$snow)
weather_raw$hail <- factor(weather_raw$hail)
weather_raw$thunder <- factor(weather_raw$thunder)
weather_raw$tornado <- factor(weather_raw$tornado)
# Danger level
# 0-1: no danger
# 2-45: small danger
# 46-90: mid danger
# 91-160: high danger
weather_raw$danger_level <- ifelse(weather_raw$Daily_accident_count>90, "High danger",
                                   ifelse(weather_raw$Daily_accident_count>45, "Mid danger",
                                          ifelse(weather_raw$Daily_accident_count>1, "Small danger", "No danger")))
weather_raw$danger_level <- factor(weather_raw$danger_level)
str(weather_raw$danger_level)
table(weather_raw$danger_level)


# ==================================================================
# Data exploration

# Explore dataset
str(weather_raw)
summary(weather_raw)
some(weather_raw)
describe(weather_raw)

# transformation for some fields

# Distribution of daily accident counts
hist_sub <- subset(weather_raw, Daily_accident_count>5)

daily_accident_count_min = min(hist_sub$Daily_accident_count)
daily_accident_count_max = max(hist_sub$Daily_accident_count)
hist_accident_count <- ggplot(hist_sub, aes(Daily_accident_count)) +
  geom_histogram(breaks=seq(daily_accident_count_min, daily_accident_count_max, by = 20),
                 col="blue",
                 aes(fill=..count..)) +
  labs(title="Daily traffic accident count from 2010-2015 in Seattle") +
  labs(x="Number of accident per day", y="Number of days") +
  scale_fill_gradient("Frequency", low = "green", high = "red") +
  ggsave(file="/resources/hist_accident_count.pdf", width=12, height=12)
hist_accident_count

# =================== NOT USEFUL ====================================
# Distribution of daily accident counts by rain
bar_rain_facet <- ggplot(hist_sub, aes(Daily_accident_count, fill=Daily_accident_count)) +
  geom_bar() +
  stat_bin(aes(label=..count..), vjust=-0.5, geom="text", position="identity") +
  guides(fill=FALSE) +
  labs(title="test") +
  labs(x="rain", y="Frequency") +
  facet_grid(rain ~ .)
bar_rain_facet

# number of accidents by Precipitation Level group by rain
table(weather_raw$rain)

density_plot_by_rain <- ggplot(weather_raw, aes(y=precipi, x=Daily_accident_count, color=rain)) +
  geom_point(shape=1, alpha=0.6) + # over plotted points will be in darker color
  geom_density2d(color="black") + # circle densely over plotted points
  scale_colour_hue(l=60) +
  geom_smooth(method=lm,   # Add linear regression lines
              se=FALSE,
              fullrange=TRUE) +
  labs(title="Number of accident per day X Precipitation Level by rain status") +
  labs(x="Number of accident per day", y="Precipitation Level") +
  scale_colour_discrete(name="rain") +
  facet_wrap(~ rain, ncol = 2) +
  ggsave(file="/resources/rain.pdf", width=12, height=12)
density_plot_by_rain


# number of accidents by visibility group by rain
density_plot_by_minvisi <- ggplot(weather_raw, aes(y=minvisi, x=Daily_accident_count, color=rain)) +
  geom_point(shape=1, alpha=0.6) + # over plotted points will be in darker color
  geom_density2d(color="black") + # circle densely over plotted points
  scale_colour_hue(l=60) +
  geom_smooth(method=lm,   # Add linear regression lines
              se=FALSE,
              fullrange=TRUE) +
  labs(title="Number of accident per day X visibility by rain status") +
  labs(x="Number of accident per day", y="visibility") +
  scale_colour_discrete(name="rain") +
  facet_wrap(~ rain, ncol = 2) +
  ggsave(file="/resources/minvisi.pdf", width=12, height=12)
density_plot_by_minvisi


# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# ================================================================
# model implementation
weather_model <- read.csv("/resources/all_traffic.csv", stringsAsFactors=FALSE)
weather_model$danger_level <- ifelse(weather_model$Daily_accident_count>90, "High danger",
                                   ifelse(weather_model$Daily_accident_count>45, "Mid danger",
                                          ifelse(weather_model$Daily_accident_count>1, "Small danger", "No danger")))
weather_model$danger_level <- factor(weather_model$danger_level)
weather_model <- weather_model[6:36]

# Preparation
num_of_row = nrow(weather_model)
num_of_col = ncol(weather_model)
weather_train <- weather_model[1:(num_of_row * 0.75), ]
weather_test <- weather_model[(num_of_row * 0.75 + 1):num_of_row, ]

# model
weather_class <- ksvm(danger_level ~ ., data=weather_train, kernel="vanilladot")
weather_class

# prediction
weather_predict <- predict(weather_class, weather_test)
table(weather_predict, weather_test$danger_level)

agreement <- weather_predict == weather_test$danger_level
table(agreement)
prop.table(table(agreement))

write.table(weather_model, "/resources/model_data.csv", sep=",")