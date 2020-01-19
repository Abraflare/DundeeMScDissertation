/**
STADIUMS
--------------------
Query showing how turf has changed over the years in stadiums
This leads to a design decison on a type 2 stadium dimension OR
a separate surface dimension
**/
select distinct seas, stad, surf
from staging.schedule
order by stad

-- Stadium does change surface but later data seems to indicate it changes back??
select distinct seas, stad, surf
from staging.schedule
where stad in ('Gillette Stadium', 'Foxboro Stadium')
order by seas

-- Example of surface change midseason, which shouldn't happen!
-- Data is unreliable, needs 2nd source to confirm?
select *
from staging.schedule
where stad = 'Gillette Stadium' and seas in (2011, 2012)
order by gid


/**
SURFACE
**/
select distinct surf
from staging.schedule;


/**
Team
**/
select *
from staging.Team;

select distinct tname
from staging.Team
order by 1

select *
from staging.Team
where tname = 'LA'

select *
from staging.schedule
where h = 'LA'

/**
Weather
**/
select top 10 *
from staging.Game

select distinct cond
from staging.Game
order by cond

select top 10 * from staging.play order by gid, pid

select top 10 * from staging.Player

select top 10 * from staging.PlayByPlay where [type] = 'PASS' and pts <> ''

select top 10 * from nfl.f_play

select min(QuarterBackID) from nfl.f_play
select min(PlayerID) from nfl.d_player