SELECT item_count as MODE
FROM items_per_order
where order_occurrences = (SELECT max(order_occurrences) from items_per_order)
ORDER BY item_count;

WITH issue_date AS (SELECT *,
DATE_Format(concat(issue_year,'-',issue_month,'-','01'),'%y-%m-%d') as launch_mth_year
FROM monthly_cards_issued),

rank_record AS (SELECT 
*,
Rank() OVER(PARTITION BY card_name ORDER BY launch_mth_year ASC) as rnk_mth_year
FROM issue_date),

launch_amount_record AS(SELECT 
card_name,
issued_amount
FROM rank_record
WHERE rnk_mth_year = 1)

SELECT * FROM launch_amount_record
ORDER BY issued_amount DESC;


#or

WITH launch_details AS (
    SELECT
        card_name,
        issue_month,
        issue_year,
        issued_amount,
        RANK() OVER (
            PARTITION BY card_name
            ORDER BY issue_year, issue_month
        ) AS rnk
    FROM monthly_cards_issued
)

SELECT
    card_name,
    issued_amount
FROM launch_details
WHERE rnk = 1
ORDER BY issued_amount DESC;

#or

WITH card_launch AS (
  SELECT 
    card_name,
    issued_amount,
    STR_TO_DATE(CONCAT(issue_year, '-', issue_month, '-01'), '%Y-%m-%d') AS issue_date,
    MIN(STR_TO_DATE(CONCAT(issue_year, '-', issue_month, '-01'), '%Y-%m-%d')) OVER (
      PARTITION BY card_name) AS launch_date
  FROM monthly_cards_issued
)

SELECT 
  card_name, 
  issued_amount
FROM card_launch
WHERE issue_date = launch_date
ORDER BY issued_amount DESC;