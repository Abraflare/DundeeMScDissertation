/**
ETL Script to take data from staging to the star schema
**/
USE NFL_Prediction;
GO

-- FIeld Zone Dimension based on ArmchairAnalysis PDF document
insert into nfl.d_field_zone (FieldZoneID, FieldZone)
values
(1, 'Own 0 -20'),
(2, 'Own 20 - 40'),
(3, 'Midfield'),
(4, 'Opp 20 - 40'),
(5, 'RedZone');
GO

-- Play Type Dimension based on ArmchairAnalysis PDF document
insert into nfl.d_play_type (PlayTypeID, PlayType)
values
(1, 'PASS'),
(2, 'RUSH');
GO

-- Player dimension scanned from the staging data
insert into nfl.d_player (AAID, PlayerName, StartYear)
select  player, fname + ' ' + lname, [start]
from staging.player;
GO

-- Stadium dimension scanned from the staging data
insert into nfl.d_stadium (StadiumName)
select distinct stad
from staging.schedule;
GO

-- Surface dimension scanned from the staging data
insert into nfl.d_surface(Surface, SurfaceType)
select distinct Surface, SurfaceType, SurfaceTypeID
from
(
	select 
		surf as Surface,
		case
			when surf = 'Grass' THEN 'Grass'
		ELSE 'Artificial' END as SurfaceType,
		case
			when surf = 'Grass' THEN 1
		ELSE 0 END as SurfaceTypeID
	from staging.schedule
) a;
GO

-- Team dimension
-- Need to work out how to model and ingest the data so that STL == LA as they are the same team
insert into nfl.d_team (TeamCode, TeamCodeID, TeamName, FullTeamName, Conference, ConferenceID)
values
('ARI', 1, 'Cardinals', 'Arizona Cardinals', 'NFC WEST', 8),
('ATL', 2, 'Falcons', 'Atlanta Falcons', 'NFC SOUTH', 7),
('BAL', 3, 'Ravens', 'Baltimore Ravens', 'AFC NORTH', 2),
('BUF', 4, 'Bills', 'Buffalo Bills', 'AFC EAST', 1),
('CAR', 5, 'Panthers', 'Carolina Panthers', 'NFC SOUTH', 7),
('CHI', 6, 'Bears', 'Chicago Bears', 'NFC NORTH', 6),
('CIN', 7, 'Bengals', 'Cincinatti Bengals', 'AFC NORTH', 2),
('CLE', 8, 'Browns', 'Cleveland Browns', 'AFC NORTH', 2),
('DAL', 9, 'Cowbowys', 'Dallas Cowboys', 'NFC EAST', 5),
('DEN', 10, 'Broncos', 'Denver Broncos', 'AFC WEST', 4),
('DET', 11, 'Lions', 'Detroit Lions', 'NFC NORTH', 6),
('GB', 12,  'Packers', 'Greenbay Packers', 'NFC NORTH', 6),
('HOU', 13, 'Texans', 'Houston Texans', 'AFC SOUTH', 3),
('IND', 14, 'Colts', 'Indianapolis Colts', 'AFC SOUTH', 3),
('JAC', 15, 'Jaguars', 'Jacksonville Jaguars', 'AFC SOUTH', 3),
('KC', 16,  'Chiefs', 'Kansas City Chiefs', 'AFC WEST', 4),
('LA', 17,  'Rams', 'Los Angeles Rams', 'NFC WEST', 8),
('STL', 17, 'Rams', 'St. Louis Rams', 'NFC WEST', 8),
('LAC', 18, 'Chargers', 'Los Angeles Chargers', 'AFC WEST', 4),
('SD', 18,  'Chargers', 'San Diego Chargers', 'AFC WEST', 4),
('MIA', 19, 'Dolphins', 'Miami Dolphins', 'AFC EAST', 1),
('MIN', 20, 'Vikings', 'Minesota Vikings', 'NFC NORTH', 6),
('NE', 21,  'Patriots', 'New England Patriots', 'AFC EAST', 1),
('NO', 22,  'Saints', 'New Orleans Saints','NFC SOUTH', 7),
('NYG', 23, 'Giants', 'New York Giants', 'NFC EAST', 5),
('NYJ', 24, 'Jets', 'New York Jets', 'AFC EAST', 1),
('OAK', 25, 'Raiders', 'Oakland Raiders', 'AFC WEST', 4),
('PHI', 26, 'Eagles', 'Philidelphia Eagles', 'NFC EAST', 5),
('PIT', 27, 'Steelers', 'Pitsburg Steelers', 'AFC NORTH', 2),
('SEA', 28, 'Seahawks', 'Seattle Seahawks', 'NFC WEST', 8),
('SF',  29, '49ers', 'San Franciso 49ers', 'NFC WEST', 8),
('TB', 30,  'Buccaneers', 'Tampa Bay Buccaneers','NFC SOUTH', 7),
('TEN', 31, 'Titans', 'Tenessee Titans', 'AFC SOUTH', 3),
('WAS', 32, 'Redskins', 'Washington Redskins', 'NFC EAST', 5);
GO

-- Weather
insert into nfl.d_weather (Condition, ConditionType, ConditionTypeID)
select distinct
	cond as Condition,
	CASE
		WHEN cond = '' THEN 'Unknown'
		WHEN cond = 'Snow' THEN 'Snow'
		WHEN cond in ('Windy', 'Thunderstorms', 'Showers', 'Rain') THEN 'Rain/Storm'
		WHEN cond in ('Light Snow', 'Flurries') THEN 'Light Snow'
		WHEN cond in ('Light Rain', 'Light Showers', 'Hazy', 'Foggy', 'Chance Rain') THEN 'Light Rain'
		ELSE 'Clear'
	END as ConditionType,
	CASE
		WHEN cond = '' THEN 1
		WHEN cond = 'Snow' THEN 2
		WHEN cond in ('Windy', 'Thunderstorms', 'Showers', 'Rain') THEN 3
		WHEN cond in ('Light Snow', 'Flurries') THEN 4
		WHEN cond in ('Light Rain', 'Light Showers', 'Hazy', 'Foggy', 'Chance Rain') THEN 5
		ELSE 6
	END as ConditionTypeID
from staging.Game
GO

-- Wind Speed
insert into nfl.d_wind_speed (WindSpeedCategory)
values
('Unknown'),
('0-10'),
('10-15'),
('15-20'),
('>20');
GO

-- Seconds buckets
insert into nfl.d_seconds_buckets(bucket)
values
('0-5'),
('5-10'),
('10-15'),
('15-20'),
('20-25'),
('25-28'),
('28-30'),
('30-35'),
('35-40'),
('40-45'),
('45-50'),
('50-55'),
('55-58'),
('58-60');
GO

-- Points Buckets
insert into nfl.d_points_buckets(Bucket)
values
('-ve40+'),
('-ve30>-ve40'),
('-ve20>-ve30'),
('-ve10>-ve20'),
('0>-ve10'),
('0-10'),
('10-20'),
('20-30'),
('30-40'),
('40+');
GO

/**
f_play fact table insertion
**/
-- truncate table nfl.f_play
insert into nfl.f_play
(
	[GameID]
	,[PlayID]
	,[OffenseID]
	,[DefenceID]
	,[FieldZoneID]
	,[PlayTypeID]
	,[MainPlayerID]
	,[WeatherID]
	,[SpeedID]
	,[StadiumID]
	,[SurfaceID]
	,[GameDate]
	,[SuccessfulPlay]
	,[Shotgun]
	,[AtHome]
	,[QBisRookie]
	,[Down]
	,[YardsToGo]
	,[NumberOfPlays]
	,[TimeoutsLeft]
	,[SecondsLeftInQuarter]
	,[SecondsLeftInHalf]
	,[SecondsLeftInGame]
	,[GameQuarter]
	,[CurrentPointsOnOffense]
	,[CurrentPointsOnDefense]
	,[PointsDifference]
	,[OffenseWinLossRatio]
	,[DefenseWinLossRatio]
	,[SeasonWeek]
)
select
	p.gid,
	p.pid,
	o.TeamID,
	d.TeamID,
	p.[zone],
	pt.PlayTypeID,
	coalesce(qb.PlayerID, rb.PlayerID),
	w.WeatherID,
	0, --ws.WindSpeedID,
	stad.StadiumID,
	surf.SurfaceID,
	sch.[date],
	1, -- successful play
	p.sg,
	CASE WHEN o.TeamCode = sch.h THEN 1 ELSE 0 END,
	CASE
		WHEN qb.StartYear = YEAR(sch.[date]) THEN 1
		ELSE 0
	END,
	p.dwn,
	p.ytg,
	p.dseq,
	p.timo,
	(p.[min] * 60) + p.sec,
	CASE
		WHEN p.qtr = 1 THEN (15*60) + (p.[min] * 60) + p.sec
		WHEN p.qtr = 2 THEN (p.[min] * 60) + p.sec
		WHEN p.qtr = 3 THEN (15*60) + (p.[min] * 60) + p.sec
		ELSE (p.[min] * 60) + p.sec
	END,
	CASE
		WHEN p.qtr = 1 THEN 3*15*60
		WHEN p.qtr = 2 THEN 2*15*60
		When p.qtr = 3 THEN 15*60
	ELSE 0 END + (p.[min] * 60) + p.sec,
	p.qtr,
	p.ptso,
	p.ptsd,
	CAST(p.ptso as int) - CAST(p.ptsd as int),
	0, -- win loss ratio O
	0, -- win loss ratio D
	sch.wk
FROM
	staging.Play p
	inner join staging.PlayByPlay pbp on p.pid = pbp.pid
	inner join staging.Schedule sch on p.gid = sch.gid
	inner join staging.Game g on p.gid = g.gid
	inner join nfl.d_play_type pt on p.[type] = pt.PlayType
	inner join nfl.d_stadium stad on sch.stad = stad.StadiumName
	inner join nfl.d_surface surf on sch.surf = surf.Surface
	inner join nfl.d_team o on o.TeamCode = p.[off]
	inner join nfl.d_team d on d.TeamCode = p.def
	inner join nfl.d_weather w on w.Condition = g.cond
	left join nfl.d_player qb on pbp.psr = qb.AAID
	left join nfl.d_player rb on pbp.bc = rb.AAID
GO

/**
Update seconds buckets
**/
WITH BucketMapping (pid, bucketGame, bucketHalf, bucketQuarter) as
(
	select
		p.PlayID as pid,
		CASE
			WHEN p.SecondsLeftInGame <= (5*60) THEN '0-5'
			WHEN p.SecondsLeftInGame <= (10*60) THEN '5-10'
			WHEN p.SecondsLeftInGame <= (15*60) THEN '10-15'
			WHEN p.SecondsLeftInGame <= (20*60) THEN '15-20'
			WHEN p.SecondsLeftInGame <= (25*60) THEN '20-25'
			WHEN p.SecondsLeftInGame <= (28*60) THEN '25-28'
			WHEN p.SecondsLeftInGame <= (30*60) THEN '28-30'
			WHEN p.SecondsLeftInGame <= (35*60) THEN '30-35'
			WHEN p.SecondsLeftInGame <= (40*60) THEN '35-40'
			WHEN p.SecondsLeftInGame <= (45*60) THEN '40-45'
			WHEN p.SecondsLeftInGame <= (50*60) THEN '45-50'
			WHEN p.SecondsLeftInGame <= (55*60) THEN '50-55'
			WHEN p.SecondsLeftInGame <= (58*60) THEN '55-58'
			ELSE '58-60'
		END as bucketGame,
		CASE
			WHEN p.SecondsLeftInHalf <= (5*60) THEN '0-5'
			WHEN p.SecondsLeftInHalf <= (10*60) THEN '5-10'
			WHEN p.SecondsLeftInHalf <= (15*60) THEN '10-15'
			WHEN p.SecondsLeftInHalf <= (20*60) THEN '15-20'
			WHEN p.SecondsLeftInHalf <= (25*60) THEN '20-25'
			WHEN p.SecondsLeftInHalf <= (28*60) THEN '25-28'
			ELSE '28-30'
		END as bucketHalf,
		CASE
			WHEN p.SecondsLeftInQuarter <= (5*60) THEN '0-5'
			WHEN p.SecondsLeftInQuarter <= (10*60) THEN '5-10'
			ELSE '10-15'
		END as bucketQuarter
	from nfl.f_play p
)
UPDATE p
SET 
	p.SecondsLeftInQuarterBucketID = bq.SecondsBucketID,
	p.SecondsLeftInHalfBucketID = bh.SecondsBucketID,
	p.SecondsLeftInGameBucketID = bg.SecondsBucketID
FROM nfl.f_play p
INNER JOIN BucketMapping mh on p.PlayID = mh.pid
INNER JOIN BucketMapping mg on p.PlayID = mg.pid
INNER JOIN BucketMapping mq on p.PlayID = mq.pid
INNER JOIN nfl.d_seconds_buckets bh on mh.bucketHalf = bh.Bucket
INNER JOIN nfl.d_seconds_buckets bg on mh.bucketGame = bg.Bucket
INNER JOIN nfl.d_seconds_buckets bq on mh.bucketQuarter = bq.Bucket
GO

/**
Update points buckets
**/
WITH BucketMapping (pid, OffenseBucket, DefenseBucket, DifferenceBucket) as
(
	SELECT
		p.PlayID as pid,
		CASE
			WHEN p.CurrentPointsOnOffense <= 10 THEN '0-10'
			WHEN p.CurrentPointsOnOffense <= 20 THEN '10-20'
			WHEN p.CurrentPointsOnOffense <= 30 THEN '20-30'
			WHEN p.CurrentPointsOnOffense <= 40 THEN '30-40'
			ELSE '40+'
		END as OffenseBucket,
		CASE
			WHEN p.CurrentPointsOnDefense <= 10 THEN '0-10'
			WHEN p.CurrentPointsOnDefense <= 20 THEN '10-20'
			WHEN p.CurrentPointsOnDefense <= 30 THEN '20-30'
			WHEN p.CurrentPointsOnDefense <= 40 THEN '30-40'
			ELSE '40+'
		END as DefenseBucket,
		CASE
			WHEN p.PointsDifference <= -40 THEN '-ve40+'
			WHEN p.PointsDifference <= -30 THEN '-ve30>-ve40'
			WHEN p.PointsDifference <= -20 THEN '-ve20>-ve30'
			WHEN p.PointsDifference <= -10 THEN '-ve10>-ve20'
			WHEN p.PointsDifference <= 0   THEN '0>-ve10'
			WHEN p.PointsDifference <= 10 THEN '0-10'
			WHEN p.PointsDifference <= 20 THEN '10-20'
			WHEN p.PointsDifference <= 30 THEN '20-30'
			WHEN p.PointsDifference <= 40 THEN '30-40'
			ELSE '40+'
		END as DifferenceBucket
	FROM nfl.f_play p
)
UPDATE p
set p.OffensePointsBucketID = opb.PointsBucketID,
	p.DefensePointsBucketID = dpb.PointsBucketID,
	p.PointsDifferenceBucketID = diffpb.PointsBucketID
FROM nfl.f_play p
INNER JOIN BucketMapping ob ON p.PlayID = ob.pid
INNER JOIN BucketMapping db ON p.PlayID = db.pid
INNER JOIN BucketMapping diff ON p.PlayID = diff.pid
INNER JOIN nfl.d_points_buckets opb on ob.OffenseBucket = opb.Bucket
INNER JOIN nfl.d_points_buckets dpb on db.DefenseBucket = dpb.Bucket
INNER JOIN nfl.d_points_buckets diffpb on diff.DifferenceBucket = diffpb.Bucket
GO


/**
Update wind speed column with more complex logic
**/
WITH WindSpeedMapping (pid, WindSpeedCategory) as
(
SELECT
	p.pid as pid,
	CASE
		WHEN wspd = '' THEN 'Unknown'
		When CAST(ltrim(rtrim(wspd)) as int) <= 10 THEN '0-10'
		WHEN CAST(ltrim(rtrim(wspd)) as int) <= 15 THEN '10-15'
		WHEN CAST(ltrim(rtrim(wspd)) as int) <= 20 THEN '15-20'
		ELSE '>20'
	END as WindSpeedCategory
FROM 
	staging.Game g
	inner join staging.Play p on g.gid = p.gid
)
UPDATE p
SET 
	p.SpeedID = ws.WindSpeedID
FROM
	nfl.f_play p
	inner join WindSpeedMapping wsm on p.PlayID = wsm.pid
	inner join nfl.d_wind_speed ws on ws.WindSpeedCategory = wsm.WindSpeedCategory
GO

-- Set the wind speed to 0-10 category for indoor, dome and covered stadiums
UPDATE nfl.f_play
SET
	SpeedID = 2
WHERE
	WeatherID in (1, 15, 21)

/**
Update successful play column with more complex logic
**/
WITH SuccessfulPlay (pid, success)
AS
(
	SELECT
		p.pid as pid,
		CASE
			WHEN p.type = 'RUSH' THEN
				CASE
					WHEN p.saf = 0 AND p.fum = 0 AND run.yds > 0 THEN 1
					ELSE 0
				END
			WHEN p.type = 'PASS' THEN
				CASE
					WHEN p.sk = 0 AND p.ints = 0 AND p.saf = 0 AND pass.comp = 1 AND pass.yds > 0 THEN 1
					ELSE 0
				END
		END as success
	FROM
		staging.Play p
		left join staging.Pass pass on p.pid = pass.pid
		left join staging.Rush run on p.pid = run.pid
	WHERE
		p.type in ('RUSH', 'PASS')
)
UPDATE p
SET
	p.SuccessfulPlay = sp.success
FROM
	nfl.f_play p
	inner join SuccessfulPlay sp on p.PlayID = sp.pid
GO
/**
Update QB Rating column with more complex logic
**/
WITH QBRating (gid, psr, n_comp, attempts, yds, tds, ints)
AS
(
	SELECT
		att.gid,
		att.psr,
		coalesce(comp.n_comp, 0),
		att.attempts,
		comp.yds,
		coalesce(td.tds, 0),
		coalesce(ints.ints, 0)
	FROM
		(select gid, psr, count(*) as attempts from staging.PlayByPlay where [type] = 'PASS' group by gid, psr) att
		left join
		(select gid, psr, count(*) as n_comp, sum(cast(yds as int)) yds from staging.PlayByPlay where [type] = 'PASS' and comp = 'Y' group by gid, psr) comp
			ON comp.gid = att.gid AND comp.psr = att.psr
		left join
		(select gid, psr, count(*) as tds from staging.PlayByPlay where [type] = 'PASS' and CAST(pts as int) > 0 group by gid, psr) td
			on comp.gid = td.gid AND comp.psr = td.psr
		left join
		(select gid, psr, count(*) as ints from staging.PlayByPlay where [type] = 'PASS' and ints <> '' group by gid, psr) ints
			on comp.gid = ints.gid and comp.psr = ints.psr
)
UPDATE p
SET
	 = (((((n_comp/attempts)-0.3)*5)+(((yds/attempts)-3)*0.25)+((tds/attempts)*20)+(2.375-((ints/attempts)*25)))/6)*100
FROM
	nfl.f_play p
	inner join QBRating qbr on p.gid = qbr.gid and p.PlayerID = qbr.psr
GO