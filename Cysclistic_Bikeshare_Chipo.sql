ALTER TABLE [dbo].[202201-divvy-tripdata]

--place first table into temp table called "data" then combine all other tables to that one using unions

DROP TABLE IF EXISTS #data 
SELECT * 
into #data
FROM [dbo].[202201-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202202-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202203-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202204-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202205-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202206-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202207-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202208-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202209-divvy-publictripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202210-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202211-divvy-tripdata]
UNION ALL 
SELECT * 
FROM [dbo].[202212-divvy-tripdata]



--check for null values 
select * from #data
where member_casual IS NULL 

--check for station null values
SELECT start_lat,start_lng, end_lat, end_lng, end_station_name, end_station_id
FROM #data 
WHERE end_lat IS NULL OR end_lng IS NULL OR start_lat IS NULL OR start_lng IS NULL 

--check for duplicate entries

SELECT ride_id, COUNT(*) as duplicate_count
FROM #data
GROUP BY ride_id
HAVING COUNT(*) > 1 --no duplicate entries

--change data types

ALTER TABLE #data
ALTER COLUMN started_at DATETIME

-- compute ride duration, use absolute to work around negative values
SELECT started_at, ended_at, ABS(DATEDIFF(HH, started_at, ended_at)) as ride_duration
FROM #data 
ORDER BY 3 DESC

--create duration columns 

ALTER TABLE #data
ADD hours_duration int,
days_duration int,
minutes_duration int


--populate just created columns; hour_duration, days_duration

UPDATE #data
SET hours_duration = ABS(DATEDIFF(HH, started_at,ended_at)),
days_duration =  ABS(DATEDIFF(WEEKDAY, started_at,ended_at))

--++ add minutes column to data
UPDATE #data
SET minutes_duration = ABS(DATEDIFF(MINUTE, started_at, ended_at))

--adding month and weekday to data
ALTER TABLE #data
ADD ride_month nvarchar(20),
ride_day nvarchar(20)

--populating data into created columns

UPDATE #data
SET ride_month = DATENAME(MONTH, started_at),
ride_day = DATENAME(WEEKDAY, started_at)


--most popular bike type; electric bike
SELECT rideable_type, count(ride_id) number_of_users
FROM #data
group by rideable_type
order by 2 desc

--member(subscription) vs casual member; more suscription members that casual members
SELECT member_casual, count(ride_id)
FROM #data
GROUP BY member_casual
ORDER BY 2 desc



--most popular month 
SELECT count(ride_id), ride_month
FROM #data
GROUP BY ride_month
ORDER BY 1 desc -- most popular month is july

--popular weekday

SELECT count(ride_id), ride_day
FROM #data
GROUP BY ride_day
ORDER BY 1 desc -- most popular day is Saturday


-- count by station

SELECT count(ride_id), start_station_name, member_casual, start_lat,start_lng,end_lat,end_lng
FROM #data
GROUP BY start_station_name, member_casual, start_lat,start_lng,end_lat,end_lng
ORDER BY 1 desc, 3

--average ride duration

SELECT ride_day, AVG(minutes_duration) 
FROM #data
GROUP BY ride_day
ORDER BY 2 desc


