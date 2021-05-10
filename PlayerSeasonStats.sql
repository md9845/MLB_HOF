/***      HOF Predictor       ***/
/*** Summarizes data by type  ***/



/*** People ***/
-- Returns records with debut and finalGame values to exclude non-players from the results
SELECT P.playerID, nameFirst + ' ' + nameLast AS Name, bats, throws, YEAR(debut) debut, YEAR(finalGame) final, Y.NumYears 
FROM People P
LEFT JOIN (SELECT playerID, count(distinct(yearID)) AS NumYears
			FROM batting
			GROUP BY playerID) Y on P.playerID = y.playerID
WHERE debut IS NOT NULL
AND finalGame IS NOT NULL
AND NumYears >= 10
ORDER BY P.playerID


/*** HOF Inductees ***/
SELECT playerID, yearID AS indYear, votedBy, inducted
FROM HallOfFame
WHERE inducted = 1
AND category = 'Player'

UNION ALL SELECT 'riverma01', 2019, 'BBWAA', 1
UNION ALL SELECT 'mussimi01', 2019, 'BBWAA', 1
UNION ALL SELECT 'martied01', 2019, 'BBWAA', 1
UNION ALL SELECT 'hallaro01', 2019, 'BBWAA', 1
UNION ALL SELECT 'baineha01', 2019, 'Veterans', 1
UNION ALL SELECT 'smithle02', 2019, 'Veterans', 1
UNION ALL SELECT 'jeterde01', 2020, 'BBWAA', 1
UNION ALL SELECT 'walkela01', 2020, 'BBWAA', 1
UNION ALL SELECT 'simmote01', 2020, 'Veterans', 1


/*** HOF Details ***/
SELECT * 
FROM HallOfFame 
WHERE category = 'Player'




/*** Batting ***/

SELECT B.playerID, B.yearID,
SUM(G) AS G, SUM(AB) AS AB, SUM(R) AS R, SUM(H) AS H, SUM([_2B]) AS [2B], SUM([_3B]) AS [3B], SUM(HR) AS HR, 
SUM(RBI) AS RBI, SUM(SB) AS SB, SUM(CS) AS CS, SUM(BB) AS BB, SUM(SO) AS SO, SUM(IBB) AS IBB, SUM(HBP) AS HBP, SUM(SH) AS SH, SUM(SF) AS SF, SUM(GIDP) AS GIDP
FROM Batting B
INNER JOIN (SELECT DISTINCT B.playerID, B.yearID, 
			Team = CASE
				WHEN NumTeams = 1 THEN B.teamID
				ELSE 'TOT'
			END
			FROM Batting B
			INNER JOIN (SELECT playerID, yearID, COUNT(DISTINCT(teamID)) AS NumTeams
						FROM Batting
						GROUP BY playerID, yearID) N ON B.playerID = N.playerID
													AND B.yearID = N.yearID) T ON B.playerID = T.playerID
																			  AND B.yearID = T.yearID
INNER JOIN (SELECT DISTINCT B.playerID, B.yearID, 
			League = CASE
				WHEN NumLeagues = 1 THEN B.lgID
				ELSE 'MLB'
			END
			FROM Batting B
			INNER JOIN (SELECT playerID, yearID, COUNT(DISTINCT(lgID)) AS NumLeagues
						FROM Batting
						GROUP BY playerID, yearID) N ON B.playerID = N.playerID
													AND B.yearID = N.yearID) L ON B.playerID = L.playerID
																			  AND B.yearID = L.yearID
GROUP BY B.playerID, B.yearID
ORDER BY B.playerID, B.yearID


/*** Fielding  ***/

SELECT PF.playerID, PF.yearID, ISNULL(PF.P, 0) AS P, ISNULL(PF.C, 0) AS C, ISNULL(PF.[1B], 0) AS [1B], ISNULL(PF.[2B], 0) AS [2B], ISNULL(PF.[3B], 0) AS [3B], ISNULL(PF.SS, 0) AS SS, 
ISNULL(PF.[OF], 0) AS [OF], COALESCE(FOFS.LF, FOF.Glf, 0) AS LF, COALESCE(FOFS.CF, FOF.Gcf, 0) AS CF, COALESCE(FOFS.RF, FOF.Grf, 0) AS RF, 
CASE
	WHEN PF.P >= ISNULL(PF.C, 0) AND PF.P >= ISNULL(PF.[1B], 0) AND PF.P >= ISNULL(PF.[2B], 0) AND PF.P >= ISNULL(PF.[3B], 0) AND PF.P >= ISNULL(PF.SS, 0) AND PF.P >= ISNULL(PF.[OF], 0) THEN 'P' 
	WHEN PF.C >= ISNULL(PF.[1B], 0) AND PF.C >= ISNULL(PF.[2B], 0) AND PF.C >= ISNULL(PF.[3B], 0) AND PF.C >= ISNULL(PF.SS, 0) AND PF.C >= ISNULL(PF.[OF], 0) THEN 'C' 
	WHEN PF.[1B] >= ISNULL(PF.[2B], 0) AND PF.[1B] >= ISNULL(PF.[3B], 0) AND PF.[1B] >= ISNULL(PF.SS, 0) AND PF.[1B] >= ISNULL(PF.[OF], 0) THEN '1B' 
	WHEN PF.[2B] >= ISNULL(PF.[3B], 0) AND PF.[2B] >= ISNULL(PF.SS, 0) AND PF.[2B] >= ISNULL(PF.[OF], 0) THEN '2B' 
	WHEN PF.[3B] >= ISNULL(PF.SS, 0) AND PF.[3B] >= ISNULL(PF.[OF], 0) THEN '3B' 
	WHEN PF.SS >= ISNULL(PF.[OF], 0) THEN 'SS' 
	ELSE 'OF'
END AS PrimPos
FROM (SELECT *
	  FROM
	  (SELECT playerID, YearID, POS, G FROM Fielding) AS SourceTable 
	  PIVOT(SUM(G) FOR POS IN([P], 
							  [C], 
							  [1B], 
							  [2B], 
							  [3B],
							  [SS], 
							  [OF])) AS PivotTable) AS PF
LEFT JOIN (SELECT *
		   FROM
		   (SELECT playerID, YearID, POS, G FROM FieldingOFsplit) AS SourceTable 
		   PIVOT(SUM(G) FOR POS IN([LF],
								   [CF], 
								   [RF])) AS PivotTable) FOFS ON PF.playerID = FOFS.playerID
														AND PF.YearID = FOFS.YearID
LEFT JOIN (SELECT playerID, yearID, SUM(Glf) AS Glf, SUM(Gcf) AS Gcf, SUM(Grf) AS Grf FROM FieldingOF GROUP BY playerID, yearID) FOF ON PF.playerID = FOF.playerID
						AND PF.YearID = FOF.YearID

/*** Pitching ***/

SELECT P.playerID, P.yearID, 
SUM(W) AS W, SUM(L) AS L, SUM(G) AS G, SUM(GS) AS GS, SUM(CG) AS CG, SUM(SHO) AS SHO, SUM(SV) AS SV, 
SUM(IPouts) AS IPouts, SUM(H) AS H, SUM(ER) AS ER, SUM(HR) AS HR, SUM(BB) AS BB, SUM(SO) AS SO, 
IP = CASE 
	WHEN SUM(IPouts) = 0 THEN 0.0 
	ELSE (1.0 * SUM(IPouts)/3)
END, 
ERA = CASE 
	WHEN SUM(IPouts) = 0 THEN 0.0 
	ELSE SUM(ER) / (1.0 * SUM(IPouts)/3) * 9
END,
SUM(IBB) AS IBB, SUM(WP) AS WP, SUM(HBP) AS HBP, SUM(BK) AS BK, SUM(BFP) AS BFP, SUM(GF) AS GF, SUM(R) AS R, SUM(SH) AS SH, SUM(SF) AS SF, SUM(GIDP) AS GIDP--, FIPConst
FROM Pitching P
INNER JOIN (SELECT DISTINCT P.playerID, P.yearID, 
			Team = CASE
				WHEN NumTeams = 1 THEN P.teamID
				ELSE 'TOT'
			END
			FROM Pitching P
			INNER JOIN (SELECT playerID, yearID, COUNT(DISTINCT(teamID)) AS NumTeams
						FROM Pitching
						GROUP BY playerID, yearID) N ON P.playerID = N.playerID
													AND P.yearID = N.yearID) T ON P.playerID = T.playerID
																			  AND P.yearID = T.yearID
INNER JOIN (SELECT DISTINCT P.playerID, P.yearID, 
			League = CASE
				WHEN NumLeagues = 1 THEN P.lgID
				ELSE 'MLB'
			END
			FROM Pitching P
			INNER JOIN (SELECT playerID, yearID, COUNT(DISTINCT(lgID)) AS NumLeagues
						FROM Pitching
						GROUP BY playerID, yearID) N ON P.playerID = N.playerID
													AND P.yearID = N.yearID) L ON P.playerID = L.playerID
																			  AND P.yearID = L.yearID
LEFT JOIN fip_constants F ON P.yearID = F.yearID
GROUP BY P.playerID, P.yearID, F.FIPConst 




/*** Batting WAR ***/

SELECT P.playerID as playerID, year_ID, WAR
FROM war_bat W
LEFT JOIN People P ON W.player_ID = P.bbrefID
WHERE pitcher = 'N'



/*** Pitching WAR ***/

SELECT P.playerID as playerID, year_ID, WAR
FROM war_pitch W
LEFT JOIN People P ON W.player_ID = P.bbrefID
WHERE IPouts > 0



/*** Awards ***/

SELECT AP.playerID, AP.yearID, ISNULL(ROY.ROY, 0) AS ROY, ISNULL(MVP.MVP, 0) AS MVP, ISNULL(CYA.CYA, 0) AS CYA, ISNULL(TC.TC, 0) AS TC, 
ISNULL(GGP.GG_P, 0) AS GG_P, ISNULL(GGC.GG_C, 0) AS GG_C, ISNULL(GG1B.GG_1B, 0) AS GG_1B, ISNULL(GG2B.GG_2B, 0) AS GG_2B, ISNULL(GG3B.GG_3B, 0) AS GG_3B, 
ISNULL(GGSS.GG_SS, 0) AS GG_SS, ISNULL(GGLF.GG_LF, 0) AS GG_LF, ISNULL(GGCF.GG_CF, 0) AS GG_CF, ISNULL(GGRF.GG_RF, 0) AS GG_RF, ISNULL(GGOF.GG_OF, 0) AS GG_OF
FROM (SELECT DISTINCT playerID, yearID FROM AwardsPlayers WHERE awardID IN ('Rookie of the Year', 'Most Valuable Player', 'Cy Young Award', 'Triple Crown', 'Gold Glove')) AP
LEFT JOIN (SELECT playerID, yearID, 1 AS ROY FROM AwardsPlayers WHERE awardID = 'Rookie of the Year') ROY ON AP.playerID = ROY.playerID 
																										 AND AP.yearID = ROY.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS MVP FROM AwardsPlayers WHERE awardID = 'Most Valuable Player') MVP ON AP.playerID = MVP.playerID 
																										   AND AP.yearID = MVP.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS CYA FROM AwardsPlayers WHERE awardID = 'Cy Young Award') CYA ON AP.playerID = CYA.playerID 
																									 AND AP.yearID = CYA.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS TC FROM AwardsPlayers WHERE awardID = 'Triple Crown') TC ON AP.playerID = TC.playerID 
																								 AND AP.yearID = TC.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_P FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = 'P') GGP ON AP.playerID = GGP.playerID 
																												  AND AP.yearID = GGP.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_C FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = 'C') GGC ON AP.playerID = GGC.playerID 
																												  AND AP.yearID = GGC.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_1B FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = '1B') GG1B ON AP.playerID = GG1B.playerID 
																													 AND AP.yearID = GG1B.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_2B FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = '2B') GG2B ON AP.playerID = GG2B.playerID 
																													 AND AP.yearID = GG2B.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_3B FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = '3B') GG3B ON AP.playerID = GG3B.playerID 
																													 AND AP.yearID = GG3B.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_SS FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = 'SS') GGSS ON AP.playerID = GGSS.playerID 
																													 AND AP.yearID = GGSS.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_LF FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = 'LF') GGLF ON AP.playerID = GGLF.playerID 
																													 AND AP.yearID = GGLF.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_CF FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = 'CF') GGCF ON AP.playerID = GGCF.playerID 
																													 AND AP.yearID = GGCF.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_RF FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = 'RF') GGRF ON AP.playerID = GGRF.playerID 
																													 AND AP.yearID = GGRF.yearID
LEFT JOIN (SELECT playerID, yearID, 1 AS GG_OF FROM AwardsPlayers WHERE awardID = 'Gold Glove' AND notes = 'OF') GGOF ON AP.playerID = GGOF.playerID 
																													 AND AP.yearID = GGOF.yearID
ORDER BY AP.playerID, AP.yearID



/*** PED ***/
SELECT playerID FROM ped

SELECT *
FROM PED P
INNER JOIN HallOfFame H ON P.playerID = H.playerID
WHERE inducted = 1


/*** Frisch Teammates ***/
SELECT DISTINCT B.playerID 
FROM Batting B
INNER JOIN (SELECT DISTINCT yearID, teamID FROM Batting WHERE playerID = 'friscfr01') F ON B.yearID = F.yearID
																					   AND B.teamID = F.teamID
INNER JOIN (SELECT playerID
			FROM HallOfFame 
			WHERE inducted = 1 
			AND YearID >= 1967 
			AND YearID <= 1973 
			AND votedBy = 'Veterans'
			AND category = 'Player') H ON B.playerID = H.playerID


SELECT *
FROM HallOfFame 
WHERE inducted = 1
AND YearID >= 1967
AND YearID <= 1973
AND votedBy = 'Veterans'
AND category = 'Player'
AND playerID IN ('bancrda01', 'hafeych01', 'haineje01', 'kellyge01', 'youngro01')


