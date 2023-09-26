# Case BellaBeat

## Intalling packages

install.packages("tidyverse")
install.packages("lubridate")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("tidyr")

library(tidyverse)
library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)

### Step 1: Import your data

daily_activity <- read.csv("Data/FitBit_Fitness_Tracker_Data/dailyActivity_merged.csv")
sleep_day <- read.csv("Data/FitBit_Fitness_Tracker_Data/sleepDay_merged.csv")
weight_log <- read.csv("Data/FitBit_Fitness_Tracker_Data/weightLogInfo_merged.csv")
hourly_steps <- read.csv("Data/FitBit_Fitness_Tracker_Data/hourlySteps_merged.csv")
heart_rate <- read.csv("Data/FitBit_Fitness_Tracker_Data/heartrate_seconds_merged.csv")
hourly_calories <- read.csv("Data/FitBit_Fitness_Tracker_Data/hourlyCalories_merged.csv")

daily_calories <- read.csv("Data/FitBit_Fitness_Tracker_Data/dailyCalories_merged.csv")
daily_steps <- read.csv("Data/FitBit_Fitness_Tracker_Data/dailySteps_merged.csv")

### Step 2: Inspecting the data

View(daily_activity)
View(sleep_day)
View(weight_log)
View(hourly_steps)
View(heart_rate)
View(hourly_calories)

View(daily_steps)
View(daily_calories)

head(daily_activity)
str(daily_activity)
glimpse(daily_activity)
colnames(daily_activity)

# Counting the number of ids (33)
length(unique(daily_activity$Id))   # 33
length(unique(sleep_day$Id))  # 24
length(unique(weight_log$Id))  # 8
length(unique(hourly_steps$Id))  # 33
length(unique(heart_rate$Id))  # 14

n_distinct(daily_activity$Id) # 33
n_distinct(heart_rate$Id) # 14

### PROCESS

## Cleaning Data

# Clean date format
daily_activity <- daily_activity %>% 
  mutate(ActivityDate = as.Date(ActivityDate, format = "%m/%d/%Y")) %>% 
  mutate(ActivityDate = format(ActivityDate, format = "%m/%d/%Y")) %>% 
  rename("Date" = "ActivityDate")
# View(daily_activity)

sleep_day <- sleep_day %>% 
  mutate(SleepDay = as.Date(SleepDay, format = "%m/%d/%Y")) %>% 
  mutate(SleepDay = format(SleepDay, format = "%m/%d/%Y")) %>% 
  rename("Date" = "SleepDay")
# View(sleep_day)

weight_log <- weight_log %>% 
  mutate(Date = as.Date(Date, format = "%m/%d/%Y")) %>% 
  mutate(Date = format(Date, format = "%m/%d/%Y"))
# View(weight_log)

daily_calories <- daily_calories %>% 
  mutate(ActivityDay = as.Date(ActivityDay, format = "%m/%d/%Y")) %>% 
  mutate(ActivityDay = format(ActivityDay, format = "%m/%d/%Y")) %>% 
  rename("Date" = "ActivityDay")
# View(daily_calories)

daily_steps <- daily_steps %>% 
  mutate(ActivityDay = as.Date(ActivityDay, format = "%m/%d/%Y")) %>% 
  mutate(ActivityDay = format(ActivityDay, format = "%m/%d/%Y")) %>% 
  rename("Date" = "ActivityDay")
# View(daily_steps)

# Transform values

# Transform date to weekday in daily activity
daily_activity$Weekday <- weekdays(as.Date(daily_activity$Date, format = "%m/%d/%Y"))
# To specify the levels in factor and then order by weekday
daily_activity$Weekday <- ordered(daily_activity$Weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
# View(daily_activity)

# Transform minutes to hours
daily_activity <- na.omit(daily_activity)
daily_activity$SedentaryHours <- round((daily_activity$SedentaryMinutes/60), 1)
daily_activity$VeryActiveHours <- round((daily_activity$VeryActiveMinutes/60), 1)
daily_activity$FairlyActiveHours <- round((daily_activity$FairlyActiveMinutes/60), 1)
daily_activity$LightlyActiveHours <- round((daily_activity$LightlyActiveMinutes/60), 1)
# View(daily_activity)

sleep_day$HoursAsleep <- round((sleep_day$TotalMinutesAsleep/60), 1)
sleep_day$HoursInBed <- round((sleep_day$TotalTimeInBed/60), 1)
# View(sleep_day)

# Transform Date time to Date and Hour
hourly_steps <- na.omit(hourly_steps)
hourly_steps <- hourly_steps[hourly_steps$StepTotal != 0, ]
hourly_steps$ActivityHour = as.POSIXct(hourly_steps$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p") 
# date
hourly_steps$Date = format(hourly_steps$ActivityHour, format = "%m/%d/%Y")
# hour
hourly_steps$Hour = format(hourly_steps$ActivityHour, format = "%H")
hourly_steps <- subset(hourly_steps, select = -ActivityHour)
# View(hourly_steps)

heart_rate <- na.omit(heart_rate)
heart_rate <- heart_rate[heart_rate$Value != 0, ]
colnames(heart_rate)[which(names(heart_rate) == "Value")] <- "HeartRate"
heart_rate$Time = as.POSIXct(heart_rate$Time, format = "%m/%d/%Y %I:%M:%S %p") 
# date
heart_rate$Date = format(heart_rate$Time, format = "%m/%d/%Y")
# hour
heart_rate$Hour = format(heart_rate$Time, format = "%H")
heart_rate <- subset(heart_rate, select = -Time)
# View(heart_rate)

hourly_calories <- na.omit(hourly_calories)
hourly_calories <- hourly_calories[hourly_calories$Calories != 0, ]
hourly_calories$ActivityHour = as.POSIXct(hourly_calories$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p") 
# date
hourly_calories$Date = format(hourly_calories$ActivityHour, format = "%m/%d/%Y")
# hour
hourly_calories$Hour = format(hourly_calories$ActivityHour, format = "%H")
hourly_calories <- subset(hourly_calories, select = -ActivityHour)
# View(hourly_calories)

## Merge Data

# Merge daily activity
complete_daily_activity <- merge(daily_activity, sleep_day, by = c("Id","Date"), match = "all")
complete_daily_activity <- merge(complete_daily_activity, weight_log, by = c("Id","Date"), match = "all")
# View(complete_daily_activity)
write_csv(complete_daily_activity, "complete_daily_activity.csv") 

# Merge hourly activity
hourly_activity <- merge(hourly_steps, heart_rate, by = c("Id","Date","Hour"), match = "all")
hourly_activity <- merge(hourly_activity, hourly_calories, by = c("Id","Date","Hour"), match = "all")
# View(hourly_activity)
write_csv(hourly_activity, "hourly_activity.csv")

# Create % data with activity and hours (for pie and bar chart)
activity_hours_average <- complete_daily_activity %>% 
  summarise(VeryActiveHours = round(mean(VeryActiveHours), 1),
            FairlyActiveHours = round(mean(FairlyActiveHours), 1),
            LightlyActiveHours = round(mean(LightlyActiveHours), 1),
            SedentaryHours = round(mean(SedentaryHours), 1))

activity_hours_average$TotalHours <- 
  sum(activity_hours_average$VeryActiveHours,
      activity_hours_average$FairlyActiveHours,
      activity_hours_average$LightlyActiveHours,
      activity_hours_average$SedentaryHours, na.rm = TRUE)

activity_hours <- data.frame(
  Activity=c('Very', 'Fairly', 'Lightly', 'Sedentary'),
  HoursPercent=c(round((activity_hours_average$VeryActiveHours/activity_hours_average$TotalHours) * 100, 0),
                 round((activity_hours_average$FairlyActiveHours/activity_hours_average$TotalHours) * 100, 0),
                 round((activity_hours_average$LightlyActiveHours/activity_hours_average$TotalHours) * 100, 0),
                 round((activity_hours_average$SedentaryHours/activity_hours_average$TotalHours) * 100, 0))
)
activity_hours$Activity <- ordered(activity_hours$Activity, levels=c("Very", "Fairly", "Lightly", "Sedentary"))

# activity_hours for bar chart
activity_hours$Hours = c(Very = activity_hours_average$VeryActiveHours,
                         Fairly = activity_hours_average$FairlyActiveHours,
                         Lightly = activity_hours_average$LightlyActiveHours,
                         Sedentary = activity_hours_average$SedentaryHours)
# View(activity_hours)
write_csv(activity_hours, "activity_hours.csv")

# averages of hourly activity
average_hourly_activity <- hourly_activity %>% 
  group_by(Hour) %>% 
  summarise(HeartRate = round(mean(HeartRate), 1), 
            TotalSteps = round(mean(StepTotal), 1),
            Calories = round(mean(Calories), 1),
            TotalCount = n())
# View(average_hourly_activity)
write_csv(average_hourly_activity, "average_hourly_activity.csv")

### ANALIZE

n_distinct(complete_daily_activity$Id) # 5
n_distinct(hourly_activity$Id) # 14

## Summary

complete_daily_activity %>% 
  select(TotalSteps, 
         TotalDistance, 
         VeryActiveHours, 
         SedentaryHours, 
         WeightKg,
         Calories, 
         HoursAsleep, 
         HoursInBed) %>% 
  summary()

hourly_activity %>% 
  select(Hour,
         HeartRate, 
         TotalSteps = StepTotal,
         Calories) %>% 
  summary()

## Plots

# scatter plot steps vs calories
ggplot(data = complete_daily_activity) +  
  geom_point(mapping = aes(x = TotalSteps, y = Calories, color=VeryActiveMinutes)) + 
  labs(title="Daily Activity: Total Steps vs. Total Calories", caption="Data Collected by Amazon Mechanical Turk 2016.") + 
  geom_smooth(mapping = aes(x = TotalSteps, y = Calories), method = lm) 
  # scale_color_gradient(low="lightblue", high="darkblue")

ggplot(data = complete_daily_activity, aes(x = TotalSteps, y = Calories, color=VeryActiveHours)) +           
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, geom = "smooth") +
  labs(title="Daily Activity: Total Steps vs. Total Calories", caption="Data Collected by Amazon Mechanical Turk 2016.") 
  # stat_smooth(method = "loess", formula = y ~ x, geom = "smooth")

# scatter plot steps vs active minutes
ggplot(data = complete_daily_activity, aes(x = TotalSteps, y = VeryActiveHours), color="steelblue1") + geom_point() + labs(title="Daily Activity: Total Steps vs. Active Hours", caption="Data Collected by Amazon Mechanical Turk 2016.") +  stat_smooth(method = "lm", formula = y ~ x, geom = "smooth")
ggplot(data = complete_daily_activity, aes(x = TotalSteps, y = FairlyActiveHours), color="indianred2") + geom_point() + labs(title="Daily Activity: Total Steps vs. Fairly Hours", caption="Data Collected by Amazon Mechanical Turk 2016.") +  stat_smooth(method = "lm", formula = y ~ x, geom = "smooth")
ggplot(data = complete_daily_activity, aes(x = TotalSteps, y = LightlyActiveHours), color="palegreen3") + geom_point() + labs(title="Daily Activity: Total Steps vs. Lightly Hours", caption="Data Collected by Amazon Mechanical Turk 2016.") +  stat_smooth(method = "lm", formula = y ~ x, geom = "smooth")
ggplot(data = complete_daily_activity, aes(x = TotalSteps, y = SedentaryHours), color="violet") + geom_point() + labs(title="Daily Activity: Total Steps vs. Sedentary Hours", caption="Data Collected by Amazon Mechanical Turk 2016.") +  stat_smooth(method = "lm", formula = y ~ x, geom = "smooth")

# activity_hours for pie chart
ggplot(activity_hours, aes(x="", y=HoursPercent, fill=Activity)) +
  geom_bar(stat="identity", color="white") +
  coord_polar("y", start=2) +
  theme_void() +
  geom_text(aes(label = paste0(HoursPercent, "%")), position = position_stack(vjust = 0.5), color = "white") +
  scale_fill_brewer(palette="Set2") +
  labs(title="Daily Activity: Activity Hours", caption="Data Collected by Amazon Mechanical Turk 2016.")

# activity_hours for bar chart
ggplot(data = activity_hours, aes(x=Activity, y=Hours, fill=Activity)) + 
  geom_bar(stat="identity") + 
  geom_text(aes(label = signif(Hours)), nudge_y = 1.5) +
  scale_fill_brewer(palette="Set2") +
  labs(x="Activity", y="Hours", title="Daily Activity: Activity vs. Hours", caption="Data Collected by Amazon Mechanical Turk 2016.")

# total steps vs day of the week
ggplot(data = complete_daily_activity, aes(x=Weekday, y=TotalSteps, fill=Weekday)) + 
  geom_bar(stat="identity") + 
  scale_fill_brewer(palette="Set2") +
  labs(title="Daily Activity: Total Steps vs. Weekday", caption="Data Collected by Amazon Mechanical Turk 2016.")

# total steps vs total distance
ggplot(data = complete_daily_activity) + 
  geom_line(mapping = aes(x = TotalSteps, y = TotalDistance), color="lightblue") +
  labs(title="Daily Activity: Total Steps vs. Total Distance", caption="Data Collected by Amazon Mechanical Turk 2016.")

# active hours vs calories
ggplot(data = complete_daily_activity) + 
  geom_line(mapping = aes(x=VeryActiveHours, y=Calories), color="indianred2") +
  labs(title="Daily Activity: Active Hours vs. Calories", caption="Data Collected by Amazon Mechanical Turk 2016.")

# total steps vs weight kg 
ggplot(data = complete_daily_activity) +  
  geom_line(mapping = aes(x = TotalSteps, y = WeightKg, color=WeightKg)) +
  scale_color_gradient(low="lightblue", high="darkblue") +
  labs(x="Total Steps",y="Weight Kg",title="Daily Activity: Total Steps vs. Weight", caption="Data Collected by Amazon Mechanical Turk 2016.")

# total steps vs hours asleep
ggplot(data = complete_daily_activity) +  
  geom_line(mapping = aes(x = HoursAsleep, y = TotalSteps, color=HoursAsleep)) +
  scale_color_gradient(low="lightblue", high="darkblue") +
  labs(x="Hours Asleep",y="Total Steps",title="Daily Activity: Hours Asleep vs. Total Steps", caption="Data Collected by Amazon Mechanical Turk 2016.")

# TotalMinutesAsleep vs TotalTimeInBed
ggplot(data = complete_daily_activity, aes(x = HoursAsleep, y = HoursInBed), color="violet") + geom_point() + labs(title="Daily Activity: Hours Asleep vs. Hours in Bed", caption="Data Collected by Amazon Mechanical Turk 2016.") +  stat_smooth(method = "lm", formula = y ~ x, geom = "smooth")

# calories vs hours asleep
ggplot(data = complete_daily_activity) +  
  geom_line(mapping = aes(x = HoursAsleep, y = Calories, color=HoursAsleep)) +
  scale_color_gradient(low="lightblue", high="darkblue") +
  labs(x="Hours Asleep",y="Calories",title="Daily Activity: Total Hours Asleep vs. Calories", caption="Data Collected by Amazon Mechanical Turk 2016.")

## Hourly data

# hours vs heart rate
ggplot(data = average_hourly_activity, aes(x=Hour, y=HeartRate, fill=Hour)) + 
  geom_bar(stat="identity") + 
  geom_text(aes(label = signif(HeartRate)), nudge_y = 2.5, size=2) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  labs(x="Hours", y="Heart Rate", title="Hourly Activity: Hours vs. Heart Rate", caption="Data Collected by Amazon Mechanical Turk 2016.")

# hours vs total steps
ggplot(data = average_hourly_activity, aes(x=Hour, y=TotalSteps, fill=Hour)) + 
  geom_bar(stat="identity") + 
  geom_text(aes(label = signif(TotalSteps)), nudge_y = 20, size=2.5) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  labs(x="Hours", y="Total Steps", title="Hourly Activity: Hours vs. Total Steps", caption="Data Collected by Amazon Mechanical Turk 2016.")

# hours vs calories
ggplot(data = average_hourly_activity, aes(x=Hour, y=Calories, fill=Hour)) + 
  geom_bar(stat="identity") + 
  geom_text(aes(label = signif(Calories)), nudge_y = 5, size=2) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
  labs(x="Hours", y="Calories", title="Hourly Activity: Hours vs. Calories", caption="Data Collected by Amazon Mechanical Turk 2016.")

# total steps vs heart rate vs calories
ggplot(data = average_hourly_activity, aes(x = TotalSteps, y = HeartRate)) +
  geom_line(aes(color = "Heart Rate")) +
  geom_line(aes(y = Calories, color = "Calories"))+
  labs(x = "Total Steps", y = "Heart Rate", color = "") +
  scale_color_manual(values = c("steelblue1", "indianred2")) +
  theme(axis.title.y = element_text(color = "indianred2", size=13)) +
  labs(title="Hourly Activity: Total Steps vs. Heart Rate vs. Calories", caption="Data Collected by Amazon Mechanical Turk 2016.")

##### 
# total steps vs heart rate
ggplot(data = average_hourly_activity)  + 
  geom_line(mapping = aes(x=TotalSteps, y=HeartRate), color="indianred2") + 
  labs(x="Total Steps", y="Heart Rate", title="Hourly Activity: Total Steps vs. Heart Rate", caption="Data Collected by Amazon Mechanical Turk 2016.")

# total steps vs calories
ggplot(data = average_hourly_activity)  + 
  geom_line(mapping = aes(x=TotalSteps, y=Calories), color="indianred2") + 
  labs(x="Total Steps", y="Calories", title="Hourly Activity: Total Steps vs. Calories", caption="Data Collected by Amazon Mechanical Turk 2016.")
#####
