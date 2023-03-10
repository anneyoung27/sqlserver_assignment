CREATE FUNCTION monthly_pay(@rate FLOAT, @periods FLOAT, @principal FLOAT)
RETURNS FLOAT
AS 
BEGIN
	DECLARE @emi FLOAT
	SET @emi = @principal / (POWER(1+@rate,@periods)-1) * (@rate*POWER(1+@rate,@periods));
	RETURN @emi;
END;
