# MLB_HOF
Predictor for Major League Baseball Hall of Fame

The Baseball Hall of Fame (HOF) recognizes and honors those who have achieved a level of excellence in the sport as a player, manager, executive or pioneer. 

Using the career records of eligible players, we will create models that attempt to predict which players will be inducted into the HOF. The models will be scored against the test dataset and the incorrect classifications considered against lists of known borderline/controversial players. The model will also be used to predict HOF induction for players not yet eligible to be included on the ballot. Finally, the model will predict which players would have been inducted if they were not known users of performance enhancing drugs (PEDs).

Each of the notebooks can be executed using the data files included in the repository. For a deeper understanding of the project workflow:
- The SQL script PlayerSeasonStats.sql extracts relevant data from a MSSQL database containing the Lahman database (http://www.seanlahman.com/baseball-archive/statistics/) plus Wins Above Replacement (WAR) data downloaded from https://www.baseball-reference.com/ and writes to csv files for processing by the notebooks
- 01 - Data Preparation uses the source data from SQL, identifies missing values, imputes, summarizes seasonal data into career totals and calculates additional features.
- 02 - EDA explores that career data looking at correlation and examining potential outliers
- 03 - Models uses different methodologies to model the data for position players/batters and pitchers to predict which players will be inducted based on their career data. There is discussion and consideration of players that are commonly believed to have external influence on their HOF candidacy which is outside the scope of the source data.

Additional background for Baseball Hall of Fame:
The first election for induction into the HOF was held in 1936. The National Baseball Hall of Fame and Museum in Cooperstown, NY opened in 1939. The specific requirements for eligibility and voting process have changed several times in the years since, but currently are:
Eligibility

    Players must have played in at least 10 seasons
    Some of the 10 seasons must have been in a period between 5 and 15 years prior to the election
    Players must have ceased playing at least five years prior to the election
    In the event of death, a player is eligible for election prior to 5 years after his final game, provided other requirements are met.
    Players on Baseball's ineligible list are not to be considered for election


Election Process

    The Baseball Writers Association of America (BBWAA) Screening Committee prepares a ballot that includes a) votes on at least 5% of ballots in the previous election or b) eligible for the first time and nominated by at least two of the six members of the committee
    BBWAA members vote for candidates on the ballot. No elector may vote for more than 10 players in an election. Players must be included on 75% of ballots cast to be elected into the HOF
    A player may remain on the ballot for a maximum of ten years. If a player is not elected in 10 years, their name is removed from the BBWAA ballot.
    Players that are no longer eligible for the BBWAA ballot may still be considered by the Era Committees, each focused on a specific period of baseball history. Committees meet on a rotating basis every five or ten years, so that one or two committees is involved in the election in any given year.

Using data from the Lahman database http://www.seanlahman.com/baseball-archive/statistics/ and baseballreference.com https://www.baseball-reference.com/data/ through the 2019 season, we will attempt to predict which players will be inducted to the HOF.

For our purposes, only Major League Baseball players are included. Negro League players or off-field personnel are not included in the models.

Definitions of statistics: https://www.baseball-reference.com/bullpen/Baseball_statistics