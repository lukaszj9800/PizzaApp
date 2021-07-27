create table pizza(
	id_pizzy int auto_increment not null primary key,
	id_nazwy int not null,
    czy_standardowa boolean
);

create table nazwa(
    id_nazwy int auto_increment not null primary key,
    nazwa varchar(100)
);

create table dodatki(
	id_dodatku int auto_increment not null primary key,
	nazwa varchar(100) not null,
	cena_standard decimal(4,2) not null
    check (cena_standard > 0)
);

create table zlaczone_dodatki(
    id_zlaczone_dodatki int auto_increment not null primary key,
    id_pizzy int not null,
    id_dodatku int not null,
    ilosc int default 1
    check (ilosc > 0)
);

create table rozmiary(
	id_rozmiaru int auto_increment not null primary key,
	nazwa varchar(10) not null,
	cena_ciasta decimal(5,2) not null,
	przeliczenie decimal(3,2) not null
    check (przeliczenie)
);

create table ciasto(
	id_ciasta int auto_increment not null primary key,
	nazwa varchar(10) not null,
	dodatek_do_ceny decimal(3,2) not null
);

create table kelner(
    id_kelnera int auto_increment not null primary key,
    imie varchar(50),
    nazwisko varchar(100),
    dodatek decimal(3, 2)
    check (dodatek > 0 AND dodatek < 1)
);

create table transakcje(
    id_transakcji int auto_increment not null primary key,
    nazwa_klienta varchar(150),
    data_zamowienia timestamp default now()
);

create table zamowione_pizze(
    id_zamowienie int auto_increment not null primary key,
    id_pizzy int not null,
    id_rozmiaru int not null,
    id_ciasta int not null,
    id_kelnera int not null,
    numer_stolika int not null,
    id_transakcji int not null,
    cena decimal(4,2) not null
    check (cena >= 0)
);

create table dodatki_laczenie_archiwum(
    id_dodatki_laczenie_archiwum int auto_increment not null primary key,
    id_pizzy int, 
    id_dodatku int,
    ilosc int,
    data_zmiany timestamp default now()
);

create table pizza_archiwum(
    id_pizza_archiwum int auto_increment not null primary key,
    id_pizzy int,
    id_nazwy int,
    czystandard boolean
);

insert into ciasto(nazwa, dodatek_do_ceny) values ("cienkie", 0), ("normalne", 0), ("grube", 2.5);

insert into rozmiary(nazwa, cena_ciasta, przeliczenie) values ("mała", 15, 1.0), ("średnia", 15.5, 1.3), ("duża", 16, 1.7);

insert into nazwa(nazwa) values ("Margherita"), ("Funghi"), ("Traffic"), ("Solo"), ("Salami");

insert into pizza(id_nazwy, czy_standardowa) values  (1, true), (2, true), (3, true), (4, true), (5, true);

insert into dodatki values (1, "sos pomidorowy", 0.5), (2, "ser", 3), (3, "oregano",0.5), (4, "pieczarki", 1), (5, "szynka", 3), (6, "salami", 3);

insert into kelner(imie, nazwisko, dodatek) values ("Jan", "Kowalski", 0.5), ("Maria", "Kot", 0.25);


insert into zlaczone_dodatki (id_pizzy, id_dodatku) values (1,1), (1,2), (1,3), 
(2,1), (2,2), (2,3), (2,4), (3,1), (3,2), (3,3), (3,4), (3,5), (4,1), (4,2),
(4,3), (4,5), (5,1), (5,2), (5,3), (5,4), (5,6);

delimiter $$
create trigger before_updating_pizza
before update
on zlaczone_dodatki for each row
begin
    declare zmienionapizzaid, zmienionydodatekid, zmienionailosc int;
    set zmienionapizzaid = old.id_pizzy;
    set zmienionydodatekid = old.id_dodatku;
    set zmienionailosc = old.ilosc;

    insert into dodatki_laczenie_archiwum(id_pizzy, id_dodatku, ilosc, data_zmiany) values (zmienionapizzaid, zmienionydodatekid, zmienionailosc, now());
end $$
delimiter ;

delimiter $$
create procedure Prowizja()
begin
    select concat(imie," ", nazwisko) Kelner, dodatek, sum(cena * dodatek) stawka from kelner join zamowione_pizze on zamowione_pizze.id_kelnera=kelner.id_kelnera  join transakcje on transakcje.id_transakcji=zamowione_pizze.id_transakcji where date(data_zamowienia) = curdate() group by kelner.id_kelnera;
end $$
delimiter ;

delimiter $$
create procedure Niestandardowe()
begin 
    select id_pizzy, count(zamowione_pizze.id_transakcji) powtorzenia from zamowione_pizze join transakcje on zamowione_pizze.id_transakcji=transakcje.id_transakcji where date(data_zamowienia) = curdate() group by id_pizzy having powtorzenia>3;
end $$
delimiter ;
