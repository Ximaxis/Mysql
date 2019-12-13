-- Селекты (Выборки)


use cours;


-- Топ 5 гильдий по очкам гильдии

select gl.name as name_guild, count(g.char_id) as summ_char, gl.guild_point as `point`
from guild_lists gl
join guilds g on g.guild_id = gl.guild_id
group by name_guild
  order by `point` desc limit 5
  ;

-- Самый активные игроки в гильдиях (по вкладу) топ 10

 select c.name as name_character, gl.name as name_guild, g.contribution as `point`
from guilds g
join guild_lists gl on g.guild_id = gl.guild_id
join `characters` c on c.char_id = g.char_id
  order by `point` desc limit 10
  ;
 
-- Новости которые понравились игрокам (вложеным запросом)

 select id as news_id, head, 
 	((select count(id) from rating_news where `status` = 'like' and news_id = n.id) 
 	- 
 	(select count(id) from rating_news where `status` = 'dislike' and news_id = n.id)) 
 		as rating_news -- из количества лайков вычитаем количество дизлайков и получаем 
from news n
order by rating_news desc
  ;
 
-- 
