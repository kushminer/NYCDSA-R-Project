
################
# project goal #
################


'A company recently introduced a new bidding type, “average bidding”, 
 as an alternative to its exisiting bidding type, called “maximum bidding”. 
 One of our clients has decided to test this new feature 
 and wants to conduct an A/B test to understand 
 if average bidding brings more conversions than maximum bidding.
 
 The A/B test ran for 1 month and the client now expects you 
 to analyze and present the results of this A/B test.
'

####################

# import block #

####################

library(dplyr)
library(ggplot2)
library(reshape2)

average_bidding <- read.csv("control_group.csv", sep = ";", header = F)
maximum_bidding <- read.csv("test_group.csv", sep = ";", header = F)


######################

# Data Preview Block #

######################

# View the first few rows of average_bidding data
head(average_bidding)

# View the first few rows of maximum_bidding data
head(maximum_bidding)

# Check the structure of average_bidding data
str(average_bidding)

# Check the structure of maximum_bidding data
str(maximum_bidding)

# Check if the number of rows is equal in both datasets
nrow_difference <- nrow(average_bidding) - nrow(maximum_bidding)
if (nrow_difference == 0) {
  print("Both datasets have the same number of rows.")
} else {
  print(paste0("Both datasets have a different number of rows. Difference: ", nrow_difference))
}

# Check if the number of columns is equal in both datasets
ncol_difference <- ncol(average_bidding) - ncol(maximum_bidding)
if (ncol_difference == 0) {
  print("Both datasets have the same number of columns.")
} else {
  print(paste0("Both datasets have a different number of columns. Difference: ", ncol_difference))
}

####################

# Quick View Block #

####################

# View Head of Data
head(average_bidding)
head(maximum_bidding)

# View Structure of Data
str(average_bidding)
str(maximum_bidding)

# Check if both datasets have the same number of rows
print(paste("Number of rows in average_bidding: ", nrow(average_bidding)))
print(paste("Number of rows in maximum_bidding: ", nrow(maximum_bidding)))

# Check if both datasets have the same number of columns
print(paste("Number of columns in average_bidding: ", ncol(average_bidding)))
print(paste("Number of columns in maximum_bidding: ", ncol(maximum_bidding)))

#######################

# Data Cleaning Block #

#######################

# Change the column names
column_names <- c("Campaign Name", "Date", "Spend (USD)",
                  "Impressions", "Reach", "Website Clicks", 
                  "Searches", "View Content", "Add to Cart", 
                  "Purchase")
colnames(maximum_bidding) <- column_names
colnames(average_bidding) <- column_names

# Remove the rows with column labels
average_bidding <- average_bidding[-1,] 
maximum_bidding <- maximum_bidding[-1,]       

# Change the data type of columns to integer
numeric_cols <- c("Spend (USD)", "Impressions", "Reach", "Website Clicks", 
                  "Searches", "View Content", "Add to Cart", "Purchase")
average_bidding[, numeric_cols] <- sapply(average_bidding[, numeric_cols], as.integer)
maximum_bidding[, numeric_cols] <- sapply(maximum_bidding[, numeric_cols], as.integer)

# Change the data type of the date column to Date
average_bidding$Date <- as.Date(average_bidding$Date, "%d.%m.%Y")
maximum_bidding$Date <- as.Date(maximum_bidding$Date, "%d.%m.%Y")

# Check for missing values
average_bidding_missing <- which(is.na(average_bidding) | average_bidding == "", arr.ind = TRUE)
average_bidding_missing_count <- sum(is.na(average_bidding))
maximum_bidding_missing <- which(is.na(maximum_bidding) | maximum_bidding == "", arr.ind = TRUE)
maximum_bidding_missing_count <- sum(is.na(maximum_bidding))

# Remove rows with missing values
average_bidding <- average_bidding[-5, ] # 7 Missing Values in this row 
maximum_bidding <- maximum_bidding[-5, ] # Removing to balance data

# Reset the row numbers
rownames(average_bidding) <- 1:nrow(average_bidding)
rownames(maximum_bidding) <- 1:nrow(maximum_bidding)


###################################

# Exploratory Data Analysis Block #

###################################

# Add Day of Week
average_bidding$day_of_week <- weekdays(average_bidding$Date)
maximum_bidding$day_of_week <- weekdays(maximum_bidding$Date)


################################

# Descriptive Statistics Block #

################################

# Set Column Names
col_names <- c("Spend (USD)", "Impressions", "Reach", "Website Clicks", "Searches", "View Content", "Add to Cart", "Purchase")

# Average Bidding Group
means_avg_bidding <- colMeans(average_bidding[, col_names], na.rm = TRUE)
stddevs_avg_bidding <- apply(average_bidding[, col_names], 2, sd, na.rm = TRUE)
q1_avg_bidding <- apply(average_bidding[, col_names], 2, quantile, probs = c(0.25), na.rm = TRUE)
q3_avg_bidding <- apply(average_bidding[, col_names], 2, quantile, probs = c(0.75), na.rm = TRUE)
iqr_avg_bidding <- q3_avg_bidding - q1_avg_bidding

desc_stats_avg_bidding <- data.frame(mean = means_avg_bidding, stddev = stddevs_avg_bidding,
                                     q1 = q1_avg_bidding, q3 = q3_avg_bidding, iqr = iqr_avg_bidding)

# Maximum Bidding Group
means_max_bidding <- colMeans(maximum_bidding[, col_names], na.rm = TRUE)
stddevs_max_bidding <- apply(maximum_bidding[, col_names], 2, sd, na.rm = TRUE)
q1_max_bidding <- apply(maximum_bidding[, col_names], 2, quantile, probs = c(0.25), na.rm = TRUE)
q3_max_bidding <- apply(maximum_bidding[, col_names], 2, quantile, probs = c(0.75), na.rm = TRUE)
iqr_max_bidding <- q3_max_bidding - q1_max_bidding

desc_stats_max_bidding <- data.frame(mean = means_max_bidding, stddev = stddevs_max_bidding,
                                     q1 = q1_max_bidding, q3 = q3_max_bidding, iqr = iqr_max_bidding)

##########################################################################################

#                                     Graphing Block                                    #

##########################################################################################


#                      select the variable and plot type for comparison                  #

# Plot Spend (USD) column
ggplot(data = average_bidding) + 
  geom_line(aes(x = Date, y = `Spend (USD)`, color = "Average Bidding")) +
  geom_line(data = maximum_bidding, aes(x = Date, y = `Spend (USD)`, color = "Maximum Bidding")) +
  ggtitle("Spend (USD) Over Time") + 
  xlab("Date") + 
  ylab("Spend (USD)") + 
  scale_color_manual(values = c("Average Bidding" = "blue", "Maximum Bidding" = "red"))

# Plot Impressions column
ggplot(data = average_bidding) + 
  geom_line(aes(x = Date, y = Impressions, color = "Average Bidding")) +
  geom_line(data = maximum_bidding, aes(x = Date, y = Impressions, color = "Maximum Bidding")) +
  ggtitle("Impressions Over Time") + 
  xlab("Date") + 
  ylab("Impressions") + 
  scale_color_manual(values = c("Average Bidding" = "blue", "Maximum Bidding" = "red"))

# Plot Reach column
ggplot(data = average_bidding) + 
  geom_line(aes(x = Date, y = Reach, color = "Average Bidding")) +
  geom_line(data = maximum_bidding, aes(x = Date, y = Reach, color = "Maximum Bidding")) +
  ggtitle("Reach Over Time") + 
  xlab("Date") + 
  ylab("Reach") + 
  scale_color_manual(values = c("Average Bidding" = "blue", "Maximum Bidding" = "red"))

# Plot Website Clicks column
ggplot(data = average_bidding) + 
  geom_line(aes(x = Date, y = `Website Clicks`, color = "Average Bidding")) +
  geom_line(data = maximum_bidding, aes(x = Date, y = `Website Clicks`, color = "Maximum Bidding")) +
  ggtitle("Website Clicks Over Time") + 
  xlab("Date") + 
  ylab("Website Clicks") + 
  scale_color_manual(values = c("Average Bidding" = "blue", "Maximum Bidding" = "red"))


#                             combine data for further plotting                          #

# Melt the data into long format
columns_to_melt <- c("Spend (USD)", "Impressions", "Reach",
                     "Website Clicks", "Searches", "View Content",
                     "Add to Cart", "Purchase")

average_bidding_melt <- melt(average_bidding, id.vars = "Date", measure.vars = columns_to_melt)
maximum_bidding_melt <- melt(maximum_bidding, id.vars = "Date", measure.vars = columns_to_melt)

# Add a column indicating the group (average_bidding or maximum_bidding)
average_bidding_melt$group <- "average_bidding"
maximum_bidding_melt$group <- "maximum_bidding"

# Combine the two melted data frames into one data frame
combined_data <- rbind(average_bidding_melt, maximum_bidding_melt)

# Add day of week
combined_data$day_of_week <- weekdays(combined_data$Date)

combined_data

#                          compare all variables of both groups                          #
  
combined_data %>% 
  group_by(day_of_week, variable) %>% 
  summarise(sum_of_values = sum(value)) %>% 
  ggplot(aes(x = day_of_week, y = sum_of_values, fill = variable)) + 
  geom_col() + 
  labs(x = "Day of the week", y = "Sum of values") + 
  ggtitle("Sum of values by day of the week and variable") + 
  facet_wrap(~ variable, ncol = 1,scales = "free_y")

# Spend Only

combined_data %>%
  filter(variable == "Spend (USD)") %>%
  group_by(day_of_week) %>%
  summarise(sum_of_values = sum(value)) %>% 
  print(n = 200)

# Spend with Percent
combined_data %>%
  filter(variable == "Spend (USD)") %>%
  group_by(day_of_week) %>%
  summarise(sum_of_values = sum(value)) %>% 
  mutate(percent_of_total = sum_of_values / sum(sum_of_values) * 100)

# As a Percent

combined_data %>%
  group_by(day_of_week, variable) %>%
  summarise(sum_of_values = sum(value)) %>%
  group_by(variable) %>%
  mutate(percent_of_total = sum_of_values / sum(sum_of_values) * 100)

# Ratio to Spend by Day of Week

combined_data %>%
  group_by(day_of_week, variable) %>%
  summarise(sum_of_values = sum(value)) %>%
  mutate(ratio = ifelse(variable != "Spend (USD)", sum_of_values / sum(sum_of_values[variable == "Spend (USD)"]), NA))

# Percent of Total by Day of Week

combined_data %>%
  group_by(day_of_week, variable) %>%
  summarise(sum_of_values = sum(value)) %>%
  group_by(variable) %>%
  mutate(percent_of_total = sum_of_values / sum(sum_of_values) * 100) %>%
  ggplot(aes(x = day_of_week, y = percent_of_total, fill = variable)) +
  geom_col() +
  geom_text(aes(label = sprintf("%1.1f%%", percent_of_total)), position = position_fill(vjust = 0.5)) +
  labs(x = "Day of the week", y = "Percent of total") +
  ggtitle("Percent of total by day of the week and variable") +
  facet_wrap(~ variable, ncol = 1, scales = "free_y")

# As a ratio of spend

spend_data <- combined_data %>%
  filter(variable == "Spend (USD)") %>%
  group_by(day_of_week) %>%
  summarise(spend = sum(value))

spend_data

combined_data_with_ratios <- combined_data %>%
  left_join(spend_data, by = c("day_of_week" = "day_of_week")) %>%
  mutate(ratio = (value / spend)*100)
combined_data_with_ratios

combined_data

combined_data %>% 
  group_by(day_of_week, variable) %>% 
  summarise(sum_of_values = sum(value)) %>% 
  mutate(ratio = sum_of_values / sum(sum_of_values[variable == "Spend (USD)"])) %>% 
  ggplot(aes(x = day_of_week, y = ratio, fill = variable)) + 
  geom_col() + 
  geom_text(aes(label = round(ratio, 2)), position = position_dodge(width = 0.9), vjust = -0.25) +
  labs(x = "Day of the week", y = "Ratio") + 
  ggtitle("Ratio of each variable to spend by day of the week") + 
  facet_wrap(~ variable, ncol = 1,scales = "free_y")

combined_data %>%
  group_by(day_of_week, variable, group) %>%
  summarise(sum_of_values = sum(value)) %>%
  mutate(ratio = sum_of_values / sum(sum_of_values[variable == "Spend (USD)"]))

# -------------------------------------------- daily facet wrap all variables

# Facet bar plot
ggplot(combined_data, aes(x = Date, y = value, fill = group)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~variable, scales = "free_y") +
  ggtitle("Bar Plot Comparison") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 90, hjust = 1))

# Facet line plot
ggplot(combined_data, aes(x = Date, y = value, color = group)) +
  geom_line(aes(group = group)) +
  facet_wrap(~variable, scales = "free_y") +
  ggtitle("Line Plot Comparison") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Stacked Plots
ggplot(combined_data, aes(x = Date, y = value, fill = group)) +
  geom_area(position = "stack") +
  ggtitle("Stacked Plot Comparsion") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~variable, scales = "free_y")

# -------------------------------------------- Aggregated Data for the month

# Aggregate data to get sum of each column
monthly_data <- combined_data %>%
  group_by(variable, group) %>%
  summarize(sum = sum(value))

# Stacked plot with facets for each column
ggplot(monthly_data, aes(x = group, y = sum, fill = group)) +
  geom_bar(stat = "identity", position = "stack") +
  geom_text(aes(label = round(sum)), position = position_stack(vjust = 0.5)) +
  facet_wrap(~variable, scales = "free_y") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

monthly_data

# -------------------------------------------- Monthly Sales to Variable Ratio : Select the Variable for a Ratio
agg_data$ratio <- 0

# Calculate the ratio of each variable to spend for the control group
agg_data$ratio[agg_data$variable != "Spend (USD)" & agg_data$group == "control"] <-  agg_data$sum[agg_data$variable == "Spend (USD)" & agg_data$group == "control"] / agg_data$sum[agg_data$variable != "Spend (USD)" & agg_data$group == "control"]

# Calculate the ratio of each variable to spend for the test group
agg_data$ratio[agg_data$variable != "Spend (USD)" & agg_data$group == "test"] <- agg_data$sum[agg_data$variable == "Spend (USD)" & agg_data$group == "test"] / agg_data$sum[agg_data$variable != "Spend (USD)" & agg_data$group == "test"]

ggplot(subset(agg_data, variable != "Spend (USD)"), aes(x = group, y = ratio, fill = group)) +
  geom_bar(stat="identity", position="stack") +
  geom_text(aes(label=round(ratio, 2)), position=position_stack(vjust=0.5)) +
  labs(x="Group", y="Ratio of Spend to Variable", fill="Group") +
  theme_minimal() +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  facet_wrap(~variable, ncol=1, scales="free_y")

# A statistical comparison to see if the values are significantly different basd on the number of obersvations

# ------------ spend / purchase, t test, 2 sample t test
combined_data spend/purchase, spend/purchase b, visualize in overlaying distribution of both
t test value

combined_data %>%
  filter(variable %in% c("Spend (USD)", "Purchase"))

combined_data %>%
  filter(variable %in% c("Spend (USD)", "Purchase")) %>%
  pivot_wider(names_from = c(variable, group), values_from = value) %>%
  select(-day_of_week) %>%
  mutate(control =  `Spend (USD)_control` / `Purchase_control`,
         test =  `Spend (USD)_test` / `Purchase_test`)


  ggplot(aes(x = control, y = test)) +
  geom_point() +
  labs(x = "Control", y = "Test") +
  ggtitle("Control vs Test")

combined_data %>%
  filter(variable %in% c("Spend (USD)", "Purchase")) %>%
  pivot_wider(names_from = c(variable, group), values_from = value) %>%
  mutate(control =  `Spend (USD)_control` / `Purchase_control`,
         test =  `Spend (USD)_test` / `Purchase_test`) %>%
  select(control,test)  %>%
  print(n=50)
    
combined_data %>%
  filter(variable %in% c("Spend (USD)", "Purchase")) %>%
  pivot_wider(names_from = c(variable, group), values_from = value) %>%
  select(-day_of_week) %>%
  mutate(control =  `Spend (USD)_control` / `Purchase_control`,
         test =  `Spend (USD)_test` / `Purchase_test`) %>% 
  ggplot(aes(x = control)) +
  geom_density(aes(fill = "control"), alpha = 0.5) +
  geom_density(aes(x = test, fill = "test"), alpha = 0.5) +
  scale_fill_manual(values = c("control" = "red", "test" = "green")) +
  ggtitle("Density Plot Overlay of Control vs Test")

# Control test has lower spend per purchase

# Statistical analysis

control <- c(3.69, 3.44, 6.30, 5.71, 4.04, 5.10, 4.11, 5.61, 2.93, 5.24, 2.92, 3.52, 2.38, 7.58, 4.62, 9.81, 7.72, 4.79, 8.95, 2.25, 7.59, 3.26, 3.23, 5.08, 8.90, 3.41, 3.77, 7.11, 3.47)
test <- c(11.8, 3.75, 4.09, 7.97, 5.04, 3.19, 6.77, 3.14, 10.1, 3.62, 3.99, 2.43, 7.46, 6.32, 6.32, 8.27, 7.70, 5.13, 3.72, 12.7, 10.5, 5.09, 7.72, 4.50, 8.14, 3.78, 3.12, 4.14, 3.46)

t.test(control, test)

wilcox.test(control, test, alternative = "two.sided")

# more days of analysis may be needed
# how many more days would be needed --> power analysis


# analyize for outliers and anamolies
