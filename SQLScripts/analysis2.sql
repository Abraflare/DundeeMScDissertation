SELECT count(*)
      --[FieldZoneID]
      --,[PlayTypeID] - 1 as [PlayTypeID]
      --,[ConditionTypeID]
      --,[SpeedID]
      --,[StadiumID]
      --,surf.[SurfaceTypeID]
      --,cast([Shotgun] as int) as Shotgun
      --,cast([AtHome] as int) as AtHome
      --,cast([QBisRookie] as int) as QBisRookie
      --,[Down]
      --,CASE
      --      WHEN yardsToGo < 11 THEN 1
      --      WHEN yardsToGo < 15 THEN 2
      --      WHEN yardsToGo < 20 THEN 3
      --      WHEN yardsToGo < 30 THEN 4
      --      ELSE 5
      -- END as yardsToGoBucket
      --,[TimeoutsLeft]
      --,qsb.SecondsBucketID as SecondsInQuarterBucketID
      --,[SecondsLeftInQuarter]/60 as [MinutesLeftInQuarter]
      --,hsb.SecondsBucketID as SecondsInHalfBucketID
      --,gsb.SecondsBucketID as SecondsInGameBucketID
      --,[GameQuarter]
      --,opb.PointsBucketID as OffensePointsBucketID
      --,dpb.PointsBucketID as DefensePointsBucketID
      --,pdb.PointsBucketID as PointsDifferenceBucketID
  FROM [NFL_Prediction].[nfl].[f_play] p
  INNER JOIN [NFL_Prediction].[nfl].[d_team] o on p.OffenseID = o.TeamID
  INNER JOIN [NFL_Prediction].[nfl].[d_team] d on p.DefenceID = d.TeamID
  INNER JOIN [NFL_Prediction].[nfl].[d_weather] w on p.WeatherID = w.WeatherID
  INNER JOIN [NFL_Prediction].[nfl].[d_surface] surf on p.SurfaceID = surf.SurfaceID
  INNER JOIN [NFL_Prediction].[nfl].[d_seconds_buckets] qsb on p.SecondsLeftInQuarterBucketID = qsb.SecondsBucketID
  INNER JOIN [NFL_Prediction].[nfl].[d_seconds_buckets] hsb on p.SecondsLeftInHalfBucketID = hsb.SecondsBucketID
  INNER JOIN [NFL_Prediction].[nfl].[d_seconds_buckets] gsb on p.SecondsLeftInHalfBucketID = gsb.SecondsBucketID
  INNER JOIN [NFL_Prediction].[nfl].[d_points_buckets] opb on p.OffensePointsBucketID = opb.PointsBucketID
  INNER JOIN [NFL_Prediction].[nfl].[d_points_buckets] dpb on p.DefensePointsBucketID = dpb.PointsBucketID
  INNER JOIN [NFL_Prediction].[nfl].[d_points_buckets] pdb on p.PointsDifferenceBucketID = pdb.PointsBucketID
  where MainPlayerID is not null
  and o.TeamName is not null
  and d.TeamName is not null
  and FieldZoneID is not null
  and PlayTypeID is not null
  and ConditionTypeID is not null
  and SpeedID is not null
  and StadiumID is not null
  and SurfaceTypeID is not null
  and cast([Shotgun] as int) is not null
  and cast([AtHome] as int) is not null
  and cast([QBisRookie] as int) is not null
  and Down is not null
  and CASE
           WHEN yardsToGo < 11 THEN 1
           WHEN yardsToGo < 15 THEN 2
           WHEN yardsToGo < 20 THEN 3
           WHEN yardsToGo < 30 THEN 4
           ELSE 5
      END is not null
  and TimeoutsLeft is not null
  and qsb.SecondsBucketID is not null
  and [SecondsLeftInQuarter]/60 is not null
  and hsb.SecondsBucketID is not null
  and gsb.SecondsBucketID is not null
  and GameQuarter is not null
  and opb.PointsBucketID is not null
  and dpb.PointsBucketID is not null
  and pdb.PointsBucketID is not null

  --639914