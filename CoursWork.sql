
drop database if exists cours;
create database cours;
use cours;

-- Тип акаунта

drop table if exists account_tipes;
create table account_tipes (
	id serial primary key,
    name VARCHAR(100)  unique
);

-- Аккаунт

drop table if exists accounts;
create table accounts (
	id_acc serial primary key,
	tipe_acc bigint unsigned,
    nickname VARCHAR(100)  unique,
    email VARCHAR(100) unique,
    age int,
    created_at datetime default now(),
    
    index (nickname),
    foreign key (tipe_acc) references account_tipes(id)
);

-- Рассы 

drop table if exists races;
create table races (
	race_id serial primary key,
	name VARCHAR(30) unique
	);

-- Классы

drop table if exists classes;
create table classes (
	class_id serial primary key,
	name VARCHAR(30) unique
	);

-- Персонажи на аккаунте

drop table if exists `characters`;
create table `characters` (
	char_id serial primary key,
	acc_id  bigint unsigned not null,
    name VARCHAR(100) unique,
    gender char (1),
    race bigint unsigned,
	class bigint unsigned,
	`level` int default(1),
    last_login datetime default now(),
        
    index (name),
    foreign key (race) references races(race_id),
    foreign key (class) references classes(class_id)
    
);

alter table `characters`
add constraint fk_acc_id
foreign key (acc_id) references accounts(id_acc)
	on update cascade 
	on delete cascade 
;

-- Почтовый ящик

drop table if exists mails;
create table mails (
	id serial primary key,
	from_acc_id bigint unsigned not null,
    to_acc_id bigint unsigned not null,
    body TEXT,
    created_at datetime default now(),
    
    index (from_acc_id),
    index (to_acc_id),
    foreign key (from_acc_id) references accounts(id_acc),
    foreign key (to_acc_id) references accounts(id_acc)
);

-- Друзья

drop table if exists friends;
create table friends (
	initiator_acc_id bigint unsigned not null,
    target_acc_id bigint unsigned not null,
    `status` ENUM('requested', 'approved', 'unfriended', 'declined'),
	requested_at datetime default now(),
	confirmed_at datetime default now(),
	
    primary key (initiator_acc_id, target_acc_id),
	index (initiator_acc_id),
    index (target_acc_id),
    foreign key (initiator_acc_id) references accounts(id_acc),
    foreign key (target_acc_id) references accounts(id_acc)
);

-- Гильдии

drop table if exists guild_lists;
create table guild_lists(
	guild_id serial primary key,
	guild_master bigint unsigned not null,
	name VARCHAR(200) unique,
	guild_point int,
	
	index (name),
	foreign key (guild_master) references `characters`(char_id)
);

-- Гильдии в которые входит персонаж

drop table if exists guilds;
create table guilds(
	char_id bigint unsigned not null,
	guild_id bigint unsigned not null,
	contribution int,
  
	primary key (char_id, guild_id)
);

alter table guilds
add constraint fk_char_id
foreign key (char_id) references `characters`(char_id)
	on update cascade 
	on delete cascade 
;

alter table guilds
add constraint fk_guild_id
foreign key (guild_id) references guild_lists(guild_id)
	on update cascade 
	on delete cascade 
;


-- Новости игры

drop table if exists news;
create table news(
	id serial primary key,
	acc_id bigint unsigned not null ,
	head VARCHAR(100),
    body text,
    created_at datetime default now(),
    updated_at datetime default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    
    index (head),
    foreign key (acc_id) references accounts(id_acc)
);

-- Лайки/дизлайки новостей

drop table if exists rating_news;
create table rating_news (
	id serial primary key,
    acc_id bigint unsigned not null,
    news_id bigint unsigned not null,
    created_at datetime default now(),
    updated_at datetime default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
    `status` ENUM('like', 'dislike'),
    
    foreign key (acc_id) references  accounts(id_acc),
    foreign key (news_id) references news(id)
);



-- Форум


-- Разделы форума

drop table if exists forum_sections;
create table forum_sections (
	id serial primary key,
	name VARCHAR(200) unique,
	
	index (name)
);

-- Под разделы форума

drop table if exists forum_subsections;
create table forum_subsections (
	id serial primary key,
	id_sect bigint unsigned not null,
	name VARCHAR(200) unique,
	
	index (name),
	foreign key (id_sect) references forum_sections(id)
);

-- Темы форума

drop table if exists forum_subjects;
create table forum_subjects (
	id serial primary key,
	name VARCHAR(200) unique,
	id_subsec bigint unsigned not null,
	created_at datetime default now(),
	
	index (name),
	foreign key (id_subsec) references forum_subsections(id)
);

-- Сообщения в темах форума

drop table if exists forum_posts;
create table forum_posts (
	id serial primary key,
	id_subjec bigint unsigned not null,
	acc_id bigint unsigned not null,
	body text,
	created_at datetime default now(),
	updated_at datetime default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
	
	foreign key (acc_id) references  accounts(id_acc),
	foreign key (id_subjec) references forum_subjects(id)
);
