/*
#1 -- SP1
1. Looping base on data di hs2_eng
2. each hs2, join with exp_custom_latest_ym, sum (value)
3. store di tabel, (hs2, total_value) 
4. make stored procedure
*/

-- answer:
CREATE TABLE hs2_sol(
	hs2 INT,
	total_value VARCHAR(11))

DROP TABLE hs2_sol;
SELECT * FROM hs2_sol;

ALTER PROCEDURE sp_1
AS 
BEGIN
	DECLARE @LoopCounter INT , @MaxHs2 INT, @Hs2 INT, @Hs2_TV VARCHAR(11)
	SELECT @LoopCounter = MIN(hs.hs2) , @MaxHs2 = MAX(hs.hs2) 
	FROM gdp_sol.dbo.hs2_eng hs 

	WHILE(@LoopCounter IS NOT NULL AND @LoopCounter <= @MaxHs2)

	BEGIN
		SELECT @Hs2 = hs.hs2 FROM gdp_sol.dbo.hs2_eng hs WHERE hs.hs2 = @LoopCounter
		SELECT @Hs2_TV = CAST(SUM(a.Value) AS VARCHAR) FROM gdp_sol.dbo.exp_custom_latest_ym a JOIN gdp_sol.dbo.hs2_eng b
						ON a.hs2 = b.hs2 WHERE b.hs2 = @LoopCounter GROUP BY b.hs2 

		INSERT INTO hs2_sol(hs2, total_value) VALUES (@Hs2, @Hs2_TV)
		SET @LoopCounter  = @LoopCounter  + 1
	END
END

EXEC sp_1 

DROP PROCEDURE sp_1;


/*
#2. -- SP2
1. select by parameter di hs2_eng
2. join with exp_custom_latest_ym, sum (value)
3. store di tabel, (hs2, total_value) -> berarti kalau hs2_name nya Cereals di hs2 = 10. nah jumlah total_Value dari hs2 = 10
4. make stored procedure with parameter
*/

-- Answer
ALTER PROCEDURE sp_2(@f_hs2 INT)
AS 
BEGIN
	BEGIN
		SELECT hs.hs2, hs.total_value FROM gdp_sol.dbo.hs2_sol AS hs
		WHERE hs.hs2 = @f_hs2 
	END
END

EXEC sp_2 42

-- Test if data is match.
SELECT b.hs2, SUM(a.Value) AS total_value FROM exp_custom_latest_ym a 
JOIN hs2_eng b 
ON a.hs2 = b.hs2
GROUP BY b.hs2 
ORDER BY b.hs2;