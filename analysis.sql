use Transactions;

# 1) Top 10 ATMs where most transactions are in the ’inactive’ state

select A.atm_number, A.atm_manufacturer, L.location, count(*) inactive_trans_count
from transactions T
join atm A
on T.atm_id = A.atm_id
join location L
on T.location_id = L.location_id
where T.atm_status = "Inactive"
group by A.atm_id
order by inactive_trans_count desc
limit 10;

/*
+------------+------------------+-------------------------+----------------------+
| atm_number | atm_manufacturer | location                | inactive_trans_count |
+------------+------------------+-------------------------+----------------------+
| 16         | NCR              | Skive                   |                44043 |
| 12         | NCR              | Østerå  Duus            |                33982 |
| 2          | NCR              | Vejgaard                |                33725 |
| 88         | NCR              | Storcenter indg. A      |                32183 |
| 30         | NCR              | Nykøbing Mors           |                30883 |
| 52         | NCR              | Farsø                   |                27361 |
| 50         | NCR              | Aarhus                  |                23416 |
| 29         | NCR              | Skelagervej 15          |                20773 |
| 81         | NCR              | Spar Købmand Tornhøj    |                20148 |
| 102        | NCR              | Aalborg Storcenter  Afd |                18297 |
+------------+------------------+-------------------------+----------------------+
10 rows in set (9.94 sec)
*/

# 2) Number of ATM failures corresponding to the different weather conditions recorded at
# the time of the transactions

with mytable
as
(select weather_main, count(*) trans_count
from transactions
group by weather_main)
select T.weather_main, M.trans_count, count(*) as inactive_count, (count(*) / M.trans_count) * 100 as inactive_count_percentage
from transactions T
join mytable M
on M.weather_main = T.weather_main
where T.atm_status = "Inactive"
group by T.weather_main
order by inactive_count_percentage desc;


/*
+--------------+-------------+----------------+---------------------------+
| weather_main | trans_count | inactive_count | inactive_count_percentage |
+--------------+-------------+----------------+---------------------------+
| Fog          |       18324 |           3785 |                   20.6560 |
| Snow         |       23548 |           4843 |                   20.5665 |
| Clouds       |     1185514 |         194727 |                   16.4255 |
| Rain         |      546845 |          86341 |                   15.7889 |
| Clear        |      545753 |          85899 |                   15.7395 |
| Mist         |       83191 |          12967 |                   15.5870 |
| Thunderstorm |        2559 |            362 |                   14.1462 |
| Drizzle      |       62797 |           8733 |                   13.9067 |
| TORNADO      |          38 |              1 |                    2.6316 |
+--------------+-------------+----------------+---------------------------+
9 rows in set (20.10 sec)
*/

# 3) Top 10 ATMs with the most number of transactions throughout the year

select A.atm_number, A.atm_manufacturer, L.location, count(*) as trans_count
from transactions T
join atm A
on T.atm_id = A.atm_id
join location L
on T.location_id = L.location_id
group by A.atm_number
order by trans_count desc
limit 10;

/*
+------------+------------------+---------------+-------------+
| atm_number | atm_manufacturer | location      | trans_count |
+------------+------------------+---------------+-------------+
| 39         | NCR              | Svenstrup     |       55380 |
| 20         | NCR              | Bispensgade   |       54211 |
| 10         | NCR              | Nørresundby   |       53794 |
| 24         | NCR              | Hobro         |       53378 |
| 45         | NCR              | Abildgaard    |       53198 |
| 16         | NCR              | Skive         |       44043 |
| 40         | Diebold Nixdorf  | Frederikshavn |       43767 |
| 1          | NCR              | Næstved       |       42787 |
| 41         | Diebold Nixdorf  | Skagen        |       42732 |
| 48         | Diebold Nixdorf  | Brønderslev   |       42493 |
+------------+------------------+---------------+-------------+
10 rows in set (4 min 38.86 sec)
*/

# 4) Number of overall ATM transactions going inactive per month for each month
with mytable
as
(select D.month, count(*) as trans_count
from transactions T
join date D
on T.date_id = D.date_id
group by D.month)
select D.year, D.month, M.trans_count, count(*) as inactive_count, (count(*) / M.trans_count) * 100 as inactive_count_percentage
from transactions T
join date D
on T.date_id = D.date_id
join mytable M
on M.month = D.month
where T.atm_status = "Inactive"
group by D.month
order by inactive_count_percentage desc;

/*
+-----------+----------------------+
+------+-----------+-------------+----------------+---------------------------+
| year | month     | trans_count | inactive_count | inactive_count_percentage |
+------+-----------+-------------+----------------+---------------------------+
| 2017 | February  |      182659 |          36656 |                   20.0680 |
| 2017 | January   |      180195 |          35953 |                   19.9523 |
| 2017 | March     |      209586 |          41046 |                   19.5843 |
| 2017 | April     |      218865 |          41830 |                   19.1122 |
| 2017 | May       |      222418 |          37679 |                   16.9406 |
| 2017 | August    |      217218 |          36713 |                   16.9015 |
| 2017 | July      |      227682 |          38139 |                   16.7510 |
| 2017 | June      |      225166 |          36789 |                   16.3386 |
| 2017 | September |      202101 |          28913 |                   14.3062 |
| 2017 | October   |      191667 |          21780 |                   11.3635 |
| 2017 | November  |      193967 |          21684 |                   11.1792 |
| 2017 | December  |      197048 |          20476 |                   10.3914 |
+------+-----------+-------------+----------------+---------------------------+
12 rows in set (16.62 sec)
*/

# 5) Top 10 ATMs with the highest total amount withdrawn throughout the year

select A.atm_number, A.atm_manufacturer, L.location, sum(transaction_amount) as total_withdrawal
from transactions T
join atm A
on T.atm_id = A.atm_id
join location L
on A.atm_location_id = L.location_id
where service = "Withdrawal"
group by A.atm_number
order by total_withdrawal desc
limit 10;


/*
+--------+------------+------------------+-----------------+------------------+
| atm_id | atm_number | atm_manufacturer | atm_location_id | total_withdrawal |
+--------+------------+------------------+-----------------+------------------+
|     52 | 39         | NCR              |              95 |        331664524 |
|     25 | 20         | NCR              |              14 |        324948309 |
|     11 | 10         | NCR              |              76 |        322159374 |
|     32 | 24         | NCR              |              40 |        320132404 |
|     60 | 45         | NCR              |              11 |        319175102 |
|     21 | 16         | NCR              |              86 |        264475589 |
|     53 | 40         | Diebold Nixdorf  |              27 |        262911714 |
|      1 | 1          | NCR              |              74 |        256553002 |
|     56 | 41         | Diebold Nixdorf  |              82 |        255966719 |
|     63 | 48         | Diebold Nixdorf  |              18 |        254546765 |
+--------+------------+------------------+-----------------+------------------+
10 rows in set (4 min 24.20 sec)
*/

# 6) Number of failed ATM transactions across various card types

with mytable
as
(select card_type_id, count(*) as total_trans_count
from transactions
group by card_type_id)
select C.card_type, M.total_trans_count, count(*) inactive_count, (count(*) / M.total_trans_count) * 100 inactive_count_percentage
from transactions T
join card_type C
on T.card_type_id = C.card_type_id
join mytable M
on T.card_type_id = M.card_type_id
where T.atm_status = "Inactive"
group by C.card_type
order by inactive_count_percentage desc;


/*
+----------------------+-------------------+----------------+---------------------------+
| card_type            | total_trans_count | inactive_count | inactive_count_percentage |
+----------------------+-------------------+----------------+---------------------------+
| Mastercard - on-us   |            458226 |          86000 |                   18.7680 |
| VISA                 |            170828 |          30713 |                   17.9789 |
| Dankort - on-us      |            143813 |          24680 |                   17.1612 |
| CIRRUS               |             17362 |           2953 |                   17.0084 |
| Hævekort - on-us     |             62487 |          10331 |                   16.5330 |
| Dankort              |             28581 |           4557 |                   15.9442 |
| MasterCard           |            400507 |          63482 |                   15.8504 |
| Visa Dankort - on-us |            748805 |         112972 |                   15.0870 |
| Hævekort             |              8459 |           1208 |                   14.2806 |
| Visa Dankort         |            427840 |          60547 |                   14.1518 |
| VisaPlus             |              1134 |            150 |                   13.2275 |
| Maestro              |               530 |             65 |                   12.2642 |
+----------------------+-------------------+----------------+---------------------------+
12 rows in set (4.78 sec)
*/

# 7) Top 10 records with the number of transactions ordered by the ATM_number,
# ATM_manufacturer, location, weekend_flag and then total_transaction_count, on
# weekdays and on weekends throughout the year

with mytable
as
(select trans_id, 
	case
		when D.weekday in ("Sunday", "Saturday") then 1
        else 0
	end as weekend_flag
from transactions T
join `date` D
on T.date_id = D.date_id)
select A.atm_number, A.atm_manufacturer, L.location, M.weekend_flag, count(*) trans_count
from transactions T
join atm A
on T.atm_id = A.atm_id
join location L
on T.location_id = L.location_id
join mytable M
on T.trans_id = M.trans_id
group by A.atm_number, M.weekend_flag;

# 8) Most active day in each ATMs from location "Vejgaard"

with mytable
as
(select 
	A.atm_number, A.atm_manufacturer, L.location, D.weekday, count(*) as trans_count,
    dense_rank() over (partition by A.atm_number order by count(*) desc) day_rank	
from transactions T
join atm A
on T.atm_id = A.atm_id
join location L
on T.location_id = L.location_id
join `date` D
on T.date_id = D.date_id
where L.location = "Vejgaard"
group by A.atm_number, D.weekday)
select atm_number, atm_manufacturer, location, weekday, trans_count 
from mytable
where day_rank = 1;

/*
+------------+------------------+----------+---------+-------------+
| atm_number | atm_manufacturer | location | weekday | trans_count |
+------------+------------------+----------+---------+-------------+
| 103        | Diebold Nixdorf  | Vejgaard | Friday  |        4757 |
| 2          | NCR              | Vejgaard | Friday  |        6290 |
+------------+------------------+----------+---------+-------------+
2 rows in set (2.74 sec)
*/








