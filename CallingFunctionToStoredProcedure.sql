CREATE FUNCTION monthly_pay(@amountToPay FLOAT, @interestRate FLOAT, @tenorInMonth INT)
RETURNS FLOAT
AS 
BEGIN
	DECLARE @emi FLOAT
	SET @emi = @amountToPay * @interestRate * POWER(1+@interestRate, @tenorInMonth)/(POWER(1+@interestRate, @tenorInMonth)-1)
	RETURN @emi;
END;

-- SELECT dbo.monthly_pay(150000000,0.08, 36)

CREATE TABLE #payment(
	TENOR INT,
	OUTSTANDING FLOAT,
	PRINCIPAL_PAYMENT FLOAT,
	INTEREST_PAYMENT FLOAT
);

ALTER PROCEDURE sp_payment_schedule(@amountToPay FLOAT, @interestRate FLOAT, @tenorInMonth INT)
AS
BEGIN
    DECLARE @interest FLOAT, @principal_payment FLOAT, @outstanding FLOAT, @loopingCounter INT = 1, @emi FLOAT
    DECLARE @outstandingBalance FLOAT = @amountToPay
    
    SET @interestRate = @interestRate / 12
    SET @emi  = dbo.monthly_pay(@amountToPay, @interestRate, @tenorInMonth)
	
	INSERT INTO #payment VALUES(0, @amountToPay, 0, 0)
    WHILE (@loopingCounter IS NOT NULL AND @loopingCounter <= @tenorInMonth)
    BEGIN
        SET @interest = IIF(@loopingCounter<=@tenorInMonth, CONVERT(DECIMAL(20,2), @outstandingBalance*@interestRate), 0)
        SET @principal_payment = IIF(@loopingCounter<=@tenorInMonth, CONVERT(DECIMAL(20,2), @emi-@interest), 0)
        SET @outstanding = IIF(@loopingCounter<=@tenorInMonth, CONVERT(DECIMAL(20,2), @outstandingBalance-@principal_payment), 0)

        INSERT INTO #payment(tenor, outstanding, principal_payment, interest_payment) 
		VALUES (@loopingCounter, @outstanding, @principal_payment, @Interest)

        SET @outstandingBalance = @outstanding
        SET @loopingCounter = @loopingCounter + 1
    END
	SELECT * FROM #payment;
END

-- DROP PROCEDURE sp_payment_schedule;

-- DROP TABLE #payment;