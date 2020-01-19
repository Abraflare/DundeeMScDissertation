CREATE OR ALTER PROCEDURE GenerateWinLossRatio
AS
BEGIN
SET NOCOUNT ON

CREATE TABLE #GameWins
(
    ROWID int identity(1,1) primary key,
	gid int,
    season int,
	wk int,
	team varchar(50),
	wins int
)

insert into #GameWins
select *
from
	(select
		gid,
		seas as season,
		wk,
		h as team,
		case
			when ptsh - ptsv > 0 THEN 1
			ELSE -1
		END as wins
	from staging.game
	union all
	select
		gid,
		seas as season,
		wk,
		v as team,
		case
			when ptsv - ptsh > 0 THEN 1
			ELSE -1
		END as wins
	from staging.game) games
order by team,season, wk

DECLARE @MAXID INT, 
		@Counter INT, 
		@PrevWk INT, 
		@PrevTeam VARCHAR(50),
		@PrevWins INT,
		@team VARCHAR(50), 
		@wk INT, 
		@wins INT,
		@tempTeam VARCHAR(50),
		@gid INT

SET @COUNTER = 1
SELECT @MAXID = COUNT(*) FROM #GameWins

UPDATE nfl.f_play
SET OffenseWinLossRatio = 0, DefenseWinLossRatio = 0

WHILE (@COUNTER <= @MAXID)
BEGIN
	
	SELECT
		@gid = gid,
		@wins = wins,
		@wk = wk,
		@team = team
	from #GameWins
	WHERE ROWID = @COUNTER
	
	PRINT 'Running for ' + @team + ' on week ' + CAST(@wk as varchar(10))

	-- If on the first iteration then pre-set the previous variables and move on
	IF (@Counter < 2)
	BEGIN
		SET @PrevWk = @wk
		SET @PrevTeam = @team
		SET @PrevWins = 0
		SET @Counter = @Counter + 1
		CONTINUE
	END

	-- Moved onto a new season or new team so reset
	IF (@wk < @PrevWk or @PrevTeam != @team)
	BEGIN
		SET @PrevWins = 0
	END

	SELECT
		@tempTeam = t.TeamCode
	FROM
		nfl.f_play p
		INNER JOIN nfl.d_team t on p.OffenseID = t.TeamID
	WHERE
		p.GameID = @gid

	--PRINT 'Received Current team is of offense or not'

	IF (@team = @tempTeam)
		UPDATE nfl.f_play
		SET OffenseWinLossRatio = @PrevWins + @wins
		WHERE GameID = @gid
	ELSE
		UPDATE nfl.f_play
		SET DefenseWinLossRatio = @PrevWins + @wins
		WHERE GameID = @gid

	PRINT 'Performed the update to ratio of ' + CAST((@PrevWins + @wins) AS VARCHAR(10))

	SET @PrevWk = @wk
	SET @PrevTeam = @team
	SET @PrevWins = @PrevWins + @wins
	SET @COUNTER = @COUNTER + 1
END


IF (OBJECT_ID('tempdb..#GameWins') IS NOT NULL)
BEGIN
    DROP TABLE #GameWins
END

END