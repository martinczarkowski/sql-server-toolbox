/*
Purpose:
  Demonstrates a transaction template with TRY/CATCH and XACT_STATE handling.

Notes:
  - Template only.
  - Replace the sample statements with your own unit of work.
  - XACT_STATE helps decide whether the transaction can still be committed or must be rolled back.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /*
      Your unit of work goes here.
      Keep transactions as short as reasonably possible.
    */

    -- Example:
    -- UPDATE dbo.SomeTable
    -- SET ProcessedAt = SYSDATETIME()
    -- WHERE ProcessedAt IS NULL;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    DECLARE @error_number int = ERROR_NUMBER();
    DECLARE @error_severity int = ERROR_SEVERITY();
    DECLARE @error_state int = ERROR_STATE();
    DECLARE @error_line int = ERROR_LINE();
    DECLARE @error_procedure nvarchar(128) = ERROR_PROCEDURE();
    DECLARE @error_message nvarchar(4000) = ERROR_MESSAGE();

    RAISERROR
    (
        'Transaction failed. Error %d, Procedure %s, Line %d: %s',
        @error_severity,
        @error_state,
        @error_number,
        @error_procedure,
        @error_line,
        @error_message
    );
END CATCH;