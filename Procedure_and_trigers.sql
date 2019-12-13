-- хранимые процедуры / триггеры;

use cours;


-- Процедура выводит таблицу показывая текущую вовлеченую аудиторию проекта в порядке убывания
  
-- Дети 0 - 13
-- Подростки 13 - 22
-- Молодые люди 22 - 35
-- Взрослые 35-45
-- Старшее поколение 45 - 99
  
DELIMITER //

drop procedure if exists core_audit //
create procedure core_audit ()
begin
	select 
	case
      when 0 <= a.age and a.age < 13 then "Child"
      when 13 <= a.age and a.age < 22 then "Tenager"
      when 22 <= a.age and a.age < 35 then "Young man"
      when 35 <= a.age and a.age < 45 then "Man"
      else "Adult"
      end as group_age,
      count(c.char_id) as summ_char, TRUNCATE(avg(c.`level`), 2) as avg_lvl,
      
      -- так как предыдущие 2 поля дают сводную информацию то выведем еще коэффициент вовлечености игроков,
      -- что бы видеть какая группа игроков стремится достигнуть максимальных уровней не забрасывая игру на раннем этапе
      -- высчитываемый из отношения среднего уровня персонажей к количеству персонажей
      
      TRUNCATE((avg(c.`level`) / count(c.char_id)), 2) as engagement_rate
  
    from accounts a
     join `characters` c  on c.acc_id = a.id_acc
    group by group_age
   order by engagement_rate desc;
    
   
end //


/*
-- Тест
call core_audit ();
*/





-- Тригеры на обновление вклада любого игрока в гильдию после каждого изменения

-- Предшествующая процедура, чтобы код не дублировался много раз
 drop procedure if exists change_contribution //
create procedure change_contribution ()
begin
	update guild_lists gl , 
	(select 
		gl.guild_id as id, sum(g.contribution) as con
	FROM guilds g 
	  join guild_lists gl
  	on gl.guild_id = g.guild_id
	group by id ) as t
SET 
guild_point = t.con
where
(gl.guild_id = t.id);

end //

-- Тригер после вставки данных
drop trigger if exists insert_contribution//
create trigger insert_contribution after insert on guilds for each row
begin
	call change_contribution ();
end; //

-- Тригер после обновления данных
drop trigger if exists update_contribution//
create trigger update_contribution after update on guilds for each row
begin
  call change_contribution ();
end; //

-- Тригер после удаления данных
drop trigger if exists delete_contribution//
create trigger delete_contribution after delete on guilds for each row
begin
  call change_contribution ();
end; //

/*
Тест тригера

insert into guilds (char_id, guild_id, contribution) values  
('1','6','2898000');

update guilds
set contribution = 99999
where char_id = 1;

delete from guilds where char_id = 1;
*/





-- Тригер на проверку является пользователь админом или модером что бы добавлять новости или вносить правки

drop trigger if exists insert_news//
create trigger insert_news before insert on news for each row
begin
  if new.acc_id = (1 or 11 or 23) -- (select id_acc from accounts where tipe_acc = 1 or tipe_acc =  2)
    then signal sqlstate '45001' set message_text = "Not rules for insert"; 
  end if;
end; //

drop trigger if exists update_news//
create trigger update_news before update on news for each row
begin
  if new.acc_id = (1 or 11 or 23) -- (select id_acc from accounts where tipe_acc = 1 or tipe_acc =  2)
    then signal sqlstate '45002' set message_text = "Not rules for update"; 
  end if;
end; //




-- Тригер меняющий группу юзера создавшего гильдию

drop trigger if exists insert_guild_lists//
create trigger insert_guild_lists after insert on guild_lists for each row
begin
update accounts, 
(select 
		gl.guild_master as gm
	FROM guild_lists gl) as g 
SET tipe_acc = 3  
where tipe_acc = 4 and (id_acc = g.gm);
end; //


DELIMITER ;
