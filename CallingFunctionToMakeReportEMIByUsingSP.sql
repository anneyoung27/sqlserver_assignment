ALTER FUNCTION monthly_pay(@amountToPay FLOAT, @interestRate FLOAT, @tenorInMonth INT)
RETURNS FLOAT
AS 
BEGIN
	DECLARE @emi FLOAT
	SET @emi = @amountToPay * @interestRate * POWER(1+@interestRate, @tenorInMonth)/(POWER(1+@interestRate, @tenorInMonth)-1)
	RETURN CONVERT(DECIMAL(20,2), @emi);
END;

-- Create table for parameter
CREATE TABLE loanPayment(
	ACCOUNT_NAME VARCHAR(50) NOT NULL UNIQUE,
	OUTSTANDING FLOAT,
	INTEREST_RATE FLOAT,
	TENOR INT,
	EMI FLOAT DEFAULT NULL);

-- Insert data into new table 
INSERT INTO loanPayment(ACCOUNT_NAME, OUTSTANDING, INTEREST_RATE, TENOR)
VALUES ('Jack',15000000,15,36),
('Row',10000000,15,15),
('Snack',12000000,15,25),
('Anne',15000000,15,36);

-- Create table for result
CREATE TABLE tb_payment_schedule(
	ACCOUNT_NAME VARCHAR(50), 
	TENOR INT, 
	OUTSTANDING FLOAT, 
	PRINCIPAL_PAYMENT FLOAT, 
	INTEREST_PAYMENT FLOAT, 
	EMI FLOAT);

-- Create a store procedure

--------------------
CREATE PROCEDURE sp_payment_schedules
AS 
BEGIN
	TRUNCATE TABLE tb_payment_schedule

	DECLARE @acc_name VARCHAR(50), @outstanding FLOAT, @interest_rate FLOAT, @tenurInMonth INT 
	DECLARE @interest FLOAT, @principal_payment FLOAT

	DECLARE @loopCounter INT 
	SET @loopCounter = 1 

	DECLARE @numRows INT 
	SELECT @numRows = COUNT(*) FROM loanPayment

	WHILE @loopCounter <= @numRows
	BEGIN
		SELECT @acc_name = ACCOUNT_NAME, 
			   @outstanding = OUTSTANDING,
			   @interest_rate = INTEREST_RATE,
			   @tenurInMonth = TENOR 
		FROM (SELECT ROW_NUMBER() OVER(ORDER BY ACCOUNT_NAME) AS RowNumber, * FROM loanPayment) AS tbl_payment 
		WhERE tbl_payment.RowNumber = @loopCounter;

		DECLARE @os FLOAT = @outstanding 
		DECLARE @emi FLOAT = dbo.monthly_pay(@outstanding, @interest_rate/1200, @tenurInMonth)
		DECLARE @tenur INT = 0 

		INSERT INTO tb_payment_schedule(ACCOUNT_NAME, TENOR, OUTSTANDING, PRINCIPAL_PAYMENT, INTEREST_PAYMENT, EMI)
		VALUES(@acc_name, 0, @os, 0, 0, @emi)

		WHILE @tenur < @tenurInMonth
		BEGIN 
			SET @tenur = @tenur + 1 
			SET @interest = IIF(@tenur <= @tenurInMonth, CONVERT(DECIMAL(20,2), @os*(@interest_rate/1200)), 0)
			SET @principal_payment = IIF(@tenur <= @tenurInMonth, CONVERT(DECIMAL(20,2), @emi-@interest), 0)
			SET @os = IIF(@tenur <= @tenurInMonth, CONVERT(DECIMAL(20,2), @os-@principal_payment), 0)

			INSERT INTO tb_payment_schedule(ACCOUNT_NAME, TENOR, OUTSTANDING, PRINCIPAL_PAYMENT, INTEREST_PAYMENT, EMI)
			VALUES(@acc_name, @tenur, @os, @principal_payment, @interest, @emi)
		END 
		SET @loopCounter = @loopCounter + 1
	END 
END

EXEC sp_payment_schedules

SELECT * FROM tb_payment_schedule;