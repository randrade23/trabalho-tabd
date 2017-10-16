CREATE TABLE Tempo (
	Tempo_ID serial,
	Hora int not null check (Hora >= 0 and Hora < 24),
	Dia int not null check (Dia >= 1 and Dia <= 31),
	Mes int not null check (Mes >= 1 and Mes <= 12),
	PRIMARY KEY (Tempo_ID)
);

CREATE TABLE Stand (
	Stand_ID serial,
	Nome VARCHAR(255) not null,
	Lotacao int not null check (Lotacao > 0),
	PRIMARY KEY (Stand_ID)
);

CREATE TABLE Taxi (
	Taxi_ID serial,
	Num_Licenca int not null check (Num_Licenca > 0),
	PRIMARY KEY (Taxi_ID)
);

CREATE TABLE Location(
    Local_ID serial,
    Stand_ID int,
    Freguesia VARCHAR(50) NOT NULL,
    Concelho VARCHAR(50) NOT NULL,
    PRIMARY KEY(Local_ID),
    FOREIGN KEY(Stand_ID) REFERENCES Stand(Stand_ID)
);

CREATE TABLE Services(
    Taxi_ID INT NOT NULL CHECK (Taxi_ID>0),
    TempoI_ID INT NOT NULL CHECK (TempoI_ID>0),
    LocalI_ID INT NOT NULL CHECK (LocalI_ID>0),
    LocalF_ID INT NOT NULL CHECK (LocalF_ID>0),
    Nr_Viagens INT NOT NULL CHECK (Nr_Viagens>0),
    Tempo_Total INT NOT NULL CHECK (Tempo_Total>=0),
    FOREIGN KEY(Taxi_ID) REFERENCES Taxi(Taxi_ID),
    FOREIGN KEY(TempoI_ID) REFERENCES Tempo(Tempo_ID),
    FOREIGN KEY(LocalI_ID) REFERENCES Location(Local_ID),
    FOREIGN KEY(LocalF_ID) REFERENCES Location(Local_ID)
);

CREATE TABLE Temp(
    ID INT NOT NULL CHECK (Taxi_ID>0),
    Taxi_ID INT NOT NULL CHECK (Taxi_ID>0),
    LocalI_ID INT,
    FreguesiaI VARCHAR(50) NOT NULL,
    ConcelhoI VARCHAR(50) NOT NULL,
    TempoI_ID INT NOT NULL,
    Initial_TS INT NOT NULL,
    HoraI int not null check (HoraI >= 0 and HoraI < 24),
    DiaI int not null check (DiaI >= 1 and DiaI <= 31),
    MesI int not null check (MesI >= 1 and MesI <= 12),
    LocalF_ID INT,
    FreguesiaF VARCHAR(50) NOT NULL,
    ConcelhoF VARCHAR(50) NOT NULL,
    TempoF_ID INT NOT NULL,
    Final_TS INT NOT NULL,
    HoraF int not null check (HoraF >= 0 and HoraF < 24),
    DiaF int not null check (DiaF >= 1 and DiaF <= 31),
    MesF int not null check (MesF >= 1 and MesF <= 12)
);
