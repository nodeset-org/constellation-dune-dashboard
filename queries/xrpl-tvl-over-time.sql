/* Track RPL transfer into xRPLVault */
WITH xRPL_transfers AS (
  SELECT
    DATE_TRUNC('day', t.block_time) AS block_date,
    SUM(
      CASE
        WHEN t."to" = 0x1DB1Afd9552eeB28e2e36597082440598B7F1320 THEN t.amount
        ELSE -t.amount
      END
    ) AS daily_flow
  FROM
    tokens.transfers t
  WHERE
    t."from" = 0x1DB1Afd9552eeB28e2e36597082440598B7F1320
    OR t."to" = 0x1DB1Afd9552eeB28e2e36597082440598B7F1320
    AND t.contract_address = 0xD33526068D116cE69F19A9ee46F0bd304F21A51f
  GROUP BY DATE_TRUNC('day', t.block_time)
),

/* Create running balance table by day */
tvl_over_time AS (
  SELECT
    block_date,
    SUM(daily_flow) OVER (ORDER BY block_date) AS cumulative_tvl
  FROM xRPL_transfers
)

SELECT
  block_date,
  cumulative_tvl AS xRPL_TVL
FROM tvl_over_time
ORDER BY block_date;
