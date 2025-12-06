# Mini ToDo Web App

Preprosta spletna aplikacija z 4 komponentami:
- HTTP strežnik (Flask)
- Aplikacija (Python logika)
- SQL baza (SQLite)
- Cache (Redis)

## Namestitev in zagon

1️⃣ **Kloniraj repozitorij:**
git clone <URL_REPO>
cd todo_web_app

2️⃣ **Namesti Python odvisnosti:**
pip install -r requirements.txt

3️⃣ **Zaženi Redis:**
docker run -d --name redis -p 6379:6379 redis

4️⃣ **Zaženi aplikacijo:**
python app.py

5️⃣ **Odpri brskalnik:**
http://localhost:5000



## 🚀 Vagrant + Cloud-init

### Osnovna ideja:

1. **Vagrantfile**:
   - Ustvari Linux VM
   - Namesti Python, pip
   - Namesti Docker
   - Zažene Redis kot container
   - Zažene Flask aplikacijo

2. **cloud-init**:
   - Uporablja YAML konfiguracijo
   - Namesti pakete, Docker, Redis
   - Ustvari mapo z aplikacijo, naloži `app.py` in `templates/`
   - Zažene Flask server


### Primer **Vagrantfile** (osnovno):

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y python3 python3-pip docker.io git
    systemctl start docker
    docker run -d --name redis -p 6379:6379 redis
    git clone <URL_REPO> /home/vagrant/todo_web_app
    cd /home/vagrant/todo_web_app
    pip3 install -r requirements.txt
    nohup python3 app.py &
  SHELL

  config.vm.network "forwarded_port", guest: 5000, host: 5000
end