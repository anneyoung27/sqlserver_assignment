CREATE FUNCTION monthly_pay(@rate FLOAT, @periods FLOAT, @principal FLOAT)
RETURNS FLOAT
AS 
BEGIN
	DECLARE @emi FLOAT
	SET @emi = @principal / (power(1+@rate,@periods)-1) * (@rate*power(1+@rate,@periods));
	RETURN @emi;
END;