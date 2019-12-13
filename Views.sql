-- Представления

use cours;

-- Самая популярные связки рассы и класса у пользователей

CREATE or replace VIEW most_popular
AS 
  select CONCAT(r.name, cl.name) as class_and_race , count(CONCAT(r.name, cl.name)) as total

  from `characters` c
   join races r on r.race_id = c.race
   join classes cl  on cl.class_id = c.class
  group by class_and_race
  order by total desc
   ;

  -- В какой ветке форума писалось больше всего постов
  
  CREATE or replace VIEW many_posts
AS 
  select fs.name as forum_sections, fss.name as forum_subsections, fsb.name as forum_subjects, count(fp.id) as total
  from forum_sections fs
   join forum_subsections fss 
   	on fss.id_sect = fs.id
   join forum_subjects fsb  
   	on fsb.id_subsec = fss.id
   join forum_posts fp  
   	on fp.id_subjec = fsb.id
  group by forum_subjects
  order by total desc
  ;
  
  -- Друзья пользователя
  
  
CREATE or replace VIEW view_friends
AS 
  select *
  from accounts a
    join friends f 
     on a.id_acc = f.target_acc_id
  where  f.status = 'approved'
  
  	union
  	
  select *
  from accounts a
    join friends f 
     on a.id_acc = f.initiator_acc_id
  where f.status = 'approved'
  