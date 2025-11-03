# DevOps: Vagrant in Cloud-init Deployment

## Pregled Projekta
Ta projekt avtomatizira namestitev full-stack spletne aplikacije **ToDo** z uporabo **Vagrant** za lokalni razvoj in **cloud-init** za namestitev v oblaku. Aplikacijski sklad vsebuje več komponent, ki skupaj omogočajo zmogljivo in varno spletno aplikacijo.

### Komponente Aplikacijskega Skalda
1. **HTTP Server / Application Server**: Flask, ki streže spletno aplikacijo preko HTTP.
2. **Application / Business Logic**: Python Flask aplikacija (`app.py`), ki upravlja dodajanje, brisanje in prikaz nalog.
3. **SQL Database**: SQLite (`tasks.db`).
4. **Cache**: Redis (Docker container), ki omogoča hiter dostop do pogosto uporabljenih podatkov.

### Značilnosti
- Dodajanje, brisanje in prikaz nalog v ToDo seznamu.
- Hiter dostop do podatkov preko Redis cache.

---

## Hitri Začetek

### Predpogoji
- **Lokalno**:
  - Vagrant
  - VirtualBox
- **V oblaku**:
  - DigitalOcean ali katerikoli provider, ki podpira cloud-init

---

### Lokalna Namestitev z Vagrant
1. Klonirajte repozitorij:  
   `git clone https://github.com/HodzaArmen/Projekt_DN`
2. Premaknite se v mapo projekta:  
   `cd Projekt_DN`
3. Zaženite VM preko Vagranta:  
   `vagrant up`
4. Dostop do aplikacije:  
   Odprite brskalnik in pojdite na `http://localhost:5000`
5. Vizualni prikaz aplikacije:  
<img width="755" height="398" alt="image" src="https://github.com/user-attachments/assets/3ccbe2c8-5888-47ee-a275-9e3111856b8a" />

---

### Namestitev v DigitalOcean Oblaku s Cloud-init
1. Ustvarite nov droplet in pri inicializaciji vnesite `cloud-init` YAML datoteko, ki je v repozitoriju.
2. Cloud-init bo samodejno:
   - namestil Python3, pip in Docker,
   - zagnal Redis container,
   - razpakiral ToDo aplikacijo,
   - namestil Python odvisnosti (Flask, Redis klient),
   - ustvaril systemd servis za avtomatski zagon aplikacije.
3. Dostop do aplikacije:  
   Odprite brskalnik in pojdite na `http://<IP_Dropleta>:5000`
4. Dostop do moje aplikacije (javna instanca):  
   [http://142.93.172.162:5000](http://142.93.172.162:5000)
5. Vizualni prikaz aplikacije:  
<img width="713" height="420" alt="image" src="https://github.com/user-attachments/assets/e6cdecfe-f439-4bec-b429-bee1f827690f" />

---

### Systemd Service
Aplikacija se zagnana kot **systemd service**, kar pomeni, da:
- Teče v ozadju po zagonu VM-ja.
- Samodejno se ponovno zažene ob morebitnem crashu.
- Zažene se z uporabnikom root in deluje v delovni mapi `/opt/todo_app/ToDo`.

---

## Člani Skupine
- Armen Hodža 
- Žan Luka Hojnik  

---

## Namen Projekta
Cilj projekta je pokazati avtomatizacijo postavitve več-komponentnega spletnega sklada (HTTP server, aplikacija, SQL baza, cache) tako lokalno kot v oblaku, z uporabo modernih DevOps orodij (Vagrant in cloud-init), ter omogočiti hitro in reproducibilno postavitev za razvoj in testiranje.
