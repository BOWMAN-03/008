-- preview data set
select top 5 * from cats;

-- 1. get all combinations of retention/version
select retention_1, retention_7, version, count(version) as user_count
from cats
group by retention_1, retention_7, version
order by version, user_count;

-- 2. average games per version
select avg(sum_gamerounds), version
from cats
group by version;

-- 3. 1 day to 7 day retention rates by version
with CTE_counts as (select
	version, count(userid) as total_players
	from cats group by version), cte_counts2 as (select cats.version, cte_counts.total_players, count(userid) as players from cte_counts 
		inner join cats
		on cte_counts.version = cats.version
		where retention_1 = 1 or retention_7 = 1
		group by Cte_counts.total_players, cats.version)
		select (1.00*players / total_players) as 'week percent retention', version, total_players, players from cte_counts2
		order by version

-- 4.  retention brackets
	select version, count(userid) as players, case
		when retention_1 = 1 and retention_7 = 1 then '1 day and 1 week'
		when retention_1 = 1 and retention_7 = 0 then '1 day'
		when retention_1 = 0 and retention_7 = 1 then 'returned only on 1 week'
		when retention_1 = 0 and retention_7 = 0 then 'no retention'
		else 'error'
		end as 'retention'
		from cats
		group by retention_1, retention_7, version
		order by version, retention

-- 5. get total in each a/b group
		select count(version), version
		from cats
		group by version;

-- 6. revises #3 to work to find difference between A/B
	with CTE_counts as (select
	version, count(userid) as total_players
	from cats group by version), cte_counts2 as (select cats.version, cte_counts.total_players, count(userid) as players from cte_counts 
		inner join cats
		on cte_counts.version = cats.version
		where retention_1 = 1 or retention_7 = 1
		group by Cte_counts.total_players, cats.version),
		CTE_counts3 as (select (1.00*players / total_players) as 'p_retention', version, total_players, players from cte_counts2)
		select top 1 lead(p_retention) over (order by p_retention)-p_retention as difference_in_p_retained from CTE_counts3;


-- 7.  revised #4 to include games played
	with cte_game as (select sum(sum_gamerounds) as games_played, version, count(userid) as players, case
		when retention_1 = 1 and retention_7 = 1 then 'retention'
		when retention_1 = 1 and retention_7 = 0 then 'half retention'
		when retention_1 = 0 and retention_7 = 1 then 'retention'
		when retention_1 = 0 and retention_7 = 0 then 'no retention'
		else 'error'
		end as 'retention'
		from cats
		group by retention_1, retention_7, version)
		select 
		sum(games_played) as games_played, version, sum(players) as player_count, retention
		from cte_game
		group by retention, version
		order by version, retention
