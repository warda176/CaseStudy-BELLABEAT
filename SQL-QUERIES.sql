
##    PREPARE AND PROCESSING DATA

#FIRST I QUERIED THE ORIGINAL DATASETS EXTRACTED FROM KAGGLE WEBSITE

# Selecting distinct IDs to find number of unique participants with daily activity data
SELECT DISTINCT Id
FROM DailyActivity
# 33 unique IDs reported in DailyActivity table
;

# Selecting unique IDs in SleepLog table
SELECT DISTINCT Id 
FROM SleepLog
# 24 unique IDs reported in SleepLog table
;

# Selecting unique IDs in WeightLog table
SELECT DISTINCT Id 
FROM WeightLog
# 8 unique IDs reported in WeightLog table
;

# Finding start and end date of data tracked in DailyActivity table
SELECT MIN(ActivityDate) AS startDate, MAX(ActivityDate) AS endDate
FROM DailyActivity
# Start date 2016-4-12, end date 2016-5-12
;

# Finding start and end date of data tracked in SleepLog table
SELECT MIN(SleepDay) AS startDate, MAX(SleepDay) AS endDate
FROM SleepLog
# Start date 2016-4-12, end date 2016-5-12
;

# Finding start and end date of data tracked in WeightLog table
SELECT MIN(Date) AS startDate, MAX(Date) AS endDate
FROM WeightLog
# Start date 2016-4-12, end date 2016-5-12
;

# Finding duplicate rows, if any, in DailyActivity
SELECT ID, ActivityDate, COUNT(*) AS numRow
FROM DailyActivity
GROUP BY ID, ActivityDate # Each row is uniquely identified by the ID and ActivityDate colummns
HAVING numRow > 1
# No results, no duplicate rows in the DailyActivity table
;

# Finding duplicate rows, if any, in SleepLog
SELECT *, COUNT(*) AS numRow
FROM SleepLog
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING numRow > 1
# 3 duplicate rows returned
;

# Creating new SleepLog table with all distinct values
CREATE TABLE SleepLog2 SELECT DISTINCT * FROM SleepLog
;

# Double checking new table no longer has duplicate rows
SELECT *, COUNT(*) AS numRow
FROM SleepLog2
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING numRow > 1
# 0 duplicate rows returned in new table; duplicate rows deleted
;

# Dropping original SleepLog table; renaming new table
ALTER TABLE SleepLog RENAME junk
DROP TABLE IF EXISTS junk;
ALTER TABLE SleepLog2 RENAME SleepLog
;

# Finding duplicate rows, if any, in WeightLog table
SELECT *, COUNT(*) AS numRow
FROM WeightLog
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
HAVING numRow > 1
# 0 duplicate rows returned
;


# Double checking that all IDs in DailyActivity have the same number of characters
SELECT LENGTH(Id)
FROM DailyActivity
;

# Looking for IDs in DailyActivity with more or less than 10 characters
SELECT Id
FROM DailyActivity
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10
# No values returned; all IDs in DailyActivity have 10 characters
;

# Looking for IDs in SleepLog with more or less than 10 characters
SELECT Id
FROM SleepLog
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10
# No values returned; all IDs in SleepLog have 10 characters
;

# Looking for IDs in WeightLog with more or less than 10 characters
SELECT Id
FROM WeightLog
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10
# No values returned; all IDs in WeightLog have 10 characters
;

# Examining records with 0 in TotalSteps column of DailyActivity table
SELECT Id, COUNT(*) AS numZeroStepsDays
FROM DailyActivity
WHERE TotalSteps = 0
GROUP BY Id
ORDER BY numZeroStepsDays DESC
# 15 participants with zero-step days
;

# Examining total number of days (records) with zero steps
SELECT SUM(numZeroStepsDays) AS totalDaysZeroSteps
FROM (
	SELECT COUNT(*) AS numZeroStepsDays
	FROM DailyActivity
	WHERE TotalSteps = 0
	) AS z
# 77 records with zero steps
;

# Looking at all attributes of each zero-step day
SELECT *, ROUND((SedentaryMinutes / 60), 2) AS SedentaryHours
FROM DailyActivity
WHERE TotalSteps = 0
# While technically possible that these records reflect days that users were wholly inactive (most records returned in the above query claim 24 total hours of sedentary activity), they're more likely reflective of days the users didn't wear their FitBits, making the records potentially misleading
;

# Deleting rows where TotalSteps = 0; see above for explanation
DELETE FROM DailyActivity
WHERE TotalSteps = 0
;



## ACTIVITTY ANALYSIS

#i created a filtered activity dataset using google sheets and sql and named it Activity_Filtered

SELECT ActivityDate,
	CASE 
    WHEN Day = 1 THEN 'Sunday-Weekend'
		WHEN Day = 2 THEN 'Monday-Weekday'
		WHEN Day = 3 THEN 'Tuesday-Weekday'
		WHEN Day = 4 THEN 'Wednesday-Weekday'
		WHEN Day = 5 THEN 'Thursday-Weekday'
		WHEN Day = 6 THEN 'Friday-Weekday'
    WHEN Day= 7 THEN 'Saturday-Weekend'
		ELSE 'No-DAY' 
	END AS PartOfWeek
FROM
	(SELECT *, EXTRACT(DAYOFWEEK FROM ActivityDate) AS Day
	FROM `my-data-project1-330110.BellaBeat.DailyActivity`
  ;
#after this i split the PartOfWeek column into DayName and WeekTime using by using Google Sheets split function and named the dataset as Activity_Filtered
#Then i queried the filtered dataset

# Selecting dates and corresponding days of the week to identify weekdays and weekends
SELECT ActivityDate, EXTRACT(DAYOFWEEK FROM ActivityDate) AS Day
FROM `my-data-project1-330110.BellaBeat.Activity_Filtered`;

#DAYOFWEEK: Returns values in the range [1,7] with Sunday as the first day of the week

SELECT ActivityDate,
	CASE 
        WHEN Day = 1 THEN 'Sunday-Weekend'
		WHEN Day = 2 THEN 'Monday-Weekday'
		WHEN Day = 3 THEN 'Tuesday-Weekday'
		WHEN Day = 4 THEN 'Wednesday-Weekday'
		WHEN Day = 5 THEN 'Thursday-Weekday'
		WHEN Day = 6 THEN 'Friday-Weekday'
        WHEN Day= 7 THEN 'Saturday-Weekend'
		ELSE 'No-DAY' 
	END AS PartOfWeek
FROM
	(SELECT *, EXTRACT(DAYOFWEEK FROM ActivityDate) AS Day
	FROM `my-data-project1-330110.BellaBeat.Activity_Filtered`) as temp;
#after this i split the PartOfWeek column into DayName and WeekTime using by using Google Sheets split function and named the dataset as Activity_Filtered
#Then i queried the filtered dataset

# Looking at average steps, distance, and calories per day of the week
SELECT DayName, AVG(TotalSteps) AS AvgSteps, AVG(TotalDistance) AS AvgDistance, AVG(Calories) AS AvgCalories
FROM `my-data-project1-330110.BellaBeat.Activity_Filtered`
GROUP BY DayName
ORDER BY AvgSteps DESC
;



## SLEEP ANALYSIS


SELECT *, 
    CASE 
		WHEN Day = 1 THEN 'Sunday-Weekend'
		WHEN Day = 2 THEN 'Monday-Weekday'
		WHEN Day= 3 THEN 'Tuesday-Weekday'
		WHEN Day= 4 THEN 'Wednesday-Weekday'
		WHEN Day = 5 THEN 'Thursday-Weekday'
		WHEN Day = 6 THEN 'Friday-Weekday'
        WHEN Day = 7 THEN 'Saturday-Weekend'
		ELSE 'No-DAY'
	END AS PartOfWeek
	FROM
		(SELECT *, EXTRACT(DAYOFWEEK FROM SleepDay) AS Day
		FROM `my-data-project1-330110.BellaBeat.Sleeplog2`) as temp;
#after this i split the PartOfWeek column into Day and TimeOfWeek using by using Google Sheets split function and named the dataset as Sleeplog_Filtered
#Then i queried the filtered dataset	

# Looking at average amount of time spent asleep and average time to fall asleep per day of the week
SELECT EXTRACT(DAYOFWEEK FROM SleepDay) AS DayOfWeek, AVG(TotalMinutesAsleep) AS AvgMinutesAsleep, AVG(TotalMinutesAsleep / 60) AS AvgHoursAsleep, AVG(TotalTimeInBed - TotalMinutesAsleep) AS AvgTimeInMinutesToFallAsleep
FROM `my-data-project1-330110.BellaBeat.Sleeplog_Filtered`
GROUP BY DayOfWeek
ORDER BY AvgHoursAsleep DESC
;

# Looking at instances where users don't have records in SleepLog based on day of the week
SELECT DayName, COUNT(*) AS users_Absent_sleepdata
FROM `my-data-project1-330110.BellaBeat.Activity_Filtered` AS d 
	LEFT JOIN `my-data-project1-330110.BellaBeat.Sleeplog_Filtered` AS s
	ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
WHERE s.TotalMinutesAsleep IS NULL
GROUP BY DayName
ORDER BY users_Absent_sleepdata DESC
;

## CALORIES ANALYSIS


# Looking at calories and active minutes
SELECT Id, ActivityDate, Calories, SedentaryMinutes, LightlyActiveMinutes, FairlyActiveMinutes, VeryActiveMinutes
FROM `my-data-project1-330110.BellaBeat.Activity_Filtered`;

# Looking at calories and total steps
SELECT Id, ActivityDate, Calories, TotalSteps
FROM `my-data-project1-330110.BellaBeat.Activity_Filtered`;



## WEIGHT ANAYSIS

# Looking at manual reports vs. automated reports in WeightLog table; also looking at average weight of participants whose reports were generated manually vs. automatically
SELECT IsManualReport, COUNT(*) AS num_reports,COUNT(DISTINCT Id) AS participants, AVG(WeightPounds) AS avg_weight
FROM `my-data-project1-330110.BellaBeat.WeightLog`
GROUP BY IsManualReport
;

