WITH xETH_transfers AS (
  SELECT
    DATE_TRUNC('day', t."tx_block_time") AS block_date,
    SUM(
      CASE
        WHEN t."to" = 0xBB22d59B73D7a6F3A8a83A214BECc67Eb3b511fE THEN t."value" / 1e18
        ELSE -t."value" / 1e18
      END
    ) AS daily_flow
  FROM
    transfers_ethereum.eth t
  WHERE
    (t."from" = 0xBB22d59B73D7a6F3A8a83A214BECc67Eb3b511fE
     OR t."to" = 0xBB22d59B73D7a6F3A8a83A214BECc67Eb3b511fE)
  GROUP BY DATE_TRUNC('day', t."tx_block_time")
 ),

tvl_over_time AS (
  SELECT
    block_date,
    SUM(daily_flow) OVER (ORDER BY block_date) AS cumulative_tvl
  FROM xETH_transfers
)

SELECT
  block_date,
  cumulative_tvl AS xETH_TVL
FROM tvl_over_time
ORDER BY block_date;