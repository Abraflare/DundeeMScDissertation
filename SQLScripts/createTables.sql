/**

Create tables for the star schema to hold the data for the NFL Games and additional data

**/
USE NFL_Prediction;
GO

--CREATE SCHEMA nfl;
--GO

IF OBJECT_ID('nfl.f_play', 'U') IS NOT NULL 
  DROP TABLE nfl.f_play;
CREATE TABLE nfl.f_play
(
	-- Foriegn Keys
	GameID int,
	PlayID int,
	OffenseID int,
	DefenceID int,
	FieldZoneID int,
	PlayTypeID int,
	MainPlayerID int,
	WeatherID int,
	SpeedID int,
	StadiumID int,
	SurfaceID int,
	GameDate date,
	-- Binary Classifications
	SuccessfulPlay bit,
	Shotgun bit,
	AtHome bit,
	QBisRookie bit,
	-- Measurements
	Down int,
	YardsToGo int,
	NumberOfPlays int,
	TimeoutsLeft int,
	SecondsLeftInQuarter int,
	SecondsLeftInQuarterBucketID int,
	SecondsLeftInHalf int,
	SecondsLeftInHalfBucketID int,
	SecondsLeftInGame int,
	SecondsLeftInGameBucketID int,
	GameQuarter int,
	CurrentPointsOnOffense int,
	OffensePointsBucketID int,
	CurrentPointsOnDefense int,
	DefensePointsBucketID int,
	PointsDifference int,
	PointsDifferenceBucketID int,
	OffenseWinLossRatio int,
	DefenseWinLossRatio int,
	SeasonWeek int
)
GO

/**
Tracking team name changes and stadium changes over the years
**/
IF OBJECT_ID('nfl.d_team', 'U') IS NOT NULL 
  DROP TABLE nfl.d_team;
CREATE TABLE nfl.d_team
(
	TeamID int IDENTITY(1,1),
	TeamCode varchar(3),
	TeamCodeID int,
	TeamName varchar(50),
	FullTeamName varchar(50),
	Conference varchar(10),
	ConferenceID int
)
GO

/**
Stadiums are a separate dimension to teams as teams can change stadiums and also play at neutral stadiums e.g. NFL London Series
**/
IF OBJECT_ID('nfl.d_stadium', 'U') IS NOT NULL 
  DROP TABLE nfl.d_stadium;
CREATE TABLE nfl.d_stadium
(
	StadiumID int IDENTITY(1,1),
	StadiumName varchar(50),
	Longitude decimal(10,7),
	Latitude decimal(10,7)
)
GO

IF OBJECT_ID('nfl.d_weather', 'U') IS NOT NULL 
  DROP TABLE nfl.d_weather;
CREATE TABLE nfl.d_weather
(
	WeatherID int IDENTITY(1,1),
	Condition varchar(50),
	ConditionType varchar(50),
	ConditionTypeID int
)
GO

IF OBJECT_ID('nfl.d_wind_speed', 'U') IS NOT NULL 
  DROP TABLE nfl.d_wind_speed;
CREATE TABLE nfl.d_wind_speed
(
	WindSpeedID int IDENTITY(1,1),
	WindSpeedCategory varchar(50)
)
GO

IF OBJECT_ID('nfl.d_surface', 'U') IS NOT NULL 
  DROP TABLE nfl.d_surface;
CREATE TABLE nfl.d_surface
(
	SurfaceID int IDENTITY(1,1),
	Surface varchar(50),
	SurfaceType varchar(50),
	SurfaceTypeID int
)
GO

IF OBJECT_ID('nfl.d_field_zone', 'U') IS NOT NULL 
  DROP TABLE nfl.d_field_zone;
CREATE TABLE nfl.d_field_zone
(
	FieldZoneID int,
	FieldZone varchar(50)
)
GO

IF OBJECT_ID('nfl.d_play_type', 'U') IS NOT NULL 
  DROP TABLE nfl.d_play_type;
CREATE TABLE nfl.d_play_type
(
	PlayTypeID int,
	PlayType varchar(50)
)
GO

IF OBJECT_ID('nfl.d_player', 'U') IS NOT NULL 
  DROP TABLE nfl.d_player;
CREATE TABLE nfl.d_player
(
	PlayerID int IDENTITY(1,1),
	AAID varchar(7),
	PlayerName varchar(50),
	StartYear int
)
GO

IF OBJECT_ID('nfl.d_seconds_buckets', 'U') IS NOT NULL
  DROP TABLE nfl.d_seconds_buckets;
CREATE TABLE nfl.d_seconds_buckets
(
	SecondsBucketID int IDENTITY(1,1),
	Bucket varchar(15)
)
GO

IF OBJECT_ID('nfl.d_points_buckets', 'U') IS NOT NULL
  DROP TABLE nfl.d_points_buckets;
CREATE TABLE nfl.d_points_buckets
(
	PointsBucketID int IDENTITY(1,1),
	Bucket varchar(15)
)