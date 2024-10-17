/* Track RPL transfer into xRPLVault */
WITH xRPL_transfers AS (
  SELECT
    DATE_TRUNC('day', t.block_time) AS block_date,
    SUM(
      CASE
        WHEN t."to" = {{xRPL_CONTRACT_ADDRESS}} THEN t.amount
        ELSE -t.amount
      END
    ) AS daily_flow
  FROM
    tokens.transfers t
  WHERE
    t."from" = {{xRPL_CONTRACT_ADDRESS}}
    OR t."to" = {{xRPL_CONTRACT_ADDRESS}}
    AND t.contract_address = {{RPL_TOKEN_ADDRESS}}
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
