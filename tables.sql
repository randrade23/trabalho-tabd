CREATE TABLE Tempo (
	Tempo_ID int not null check (Tempo_ID > 0),
	Hora int not null check (Hora >= 0 and Hora < 24),
	Dia int not null check (Dia >= 1 and Dia <= 31),
	Mes int not null check (Mes >= 1 and Mes <= 12),
	PRIMARY KEY (Tempo_ID)
);

CREATE TABLE Stand (
	Stand_ID int not null check (Stand_ID > 0),
	Nome varchar(255) not null,
	Lotacao int not null check (Lotacao > 0),
	PRIMARY KEY (Stand_ID)
);

CREATE TABLE Taxi (
	Taxi_ID int not null check (Taxi_ID > 0),
	Num_Licenca int not null check (Num_Licenca > 0),
	PRIMARY KEY (Taxi_ID)
);

CREATE TABLE Location(
    Local_ID INT NOT NULL CHECK(Local_ID>0),
    Stand_ID INT NOT NULL CHECK(Stand_ID>0),
    Freguesia VARCHAR(50) NOT NULL,
    Concelho VARCHAR(50) NOT NULL,
    PRIMARY KEY(Local_ID),
    FOREIGN KEY(Stand_ID) REFERENCES Stand(Stand_ID)
);

CREATE TABLE Services(
    Taxi_ID INT NOT NULL CHECK (Taxi_ID>0),
    Tempo_ID INT NOT NULL CHECK (Tempo_ID>0),
    LocalI_ID INT NOT NULL CHECK (LocalI_ID>0),
    LocalF_ID INT NOT NULL CHECK (LocalF_ID>0),
    Nr_Viagens INT NOT NULL CHECK (Nr_Viagens>0),
    Tempo_Total INT NOT NULL CHECK (Tempo_Total>0),
    FOREIGN KEY(Taxi_ID) REFERENCES Taxi(Taxi_ID),
    FOREIGN KEY(Tempo_ID) REFERENCES Tempo(Tempo_ID),
    FOREIGN KEY(LocalI_ID) REFERENCES Location(Local_ID),
    FOREIGN KEY(LocalF_ID) REFERENCES Location(Local_ID)
);