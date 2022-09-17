.PHONY: install configure start print-ip check stop restart kill ensure unistall

SHELL=/bin/bash
.ONESHELL:


install:
	wget -qO ~/syncthing.tar.gz https://github.com/syncthing/syncthing/releases/download/v1.9.0/syncthing-linux-amd64-v1.9.0.tar.gz
	mkdir -p ~/bin
	tar xvzf ~/syncthing.tar.gz -C ~/
	mv ~/syncthing-linux-amd64-v1.9.0/syncthing ~/bin/
	chmod +x ~/bin/syncthing
	~/bin/syncthing -generate="~/.config/syncthing"
	rm ~/syncthing.tar.gz
	rm -rf ~/syncthing-linux-amd64-v1.9.0

configure:
	sed -i 's|127.0.0.1:[0-9]*|0.0.0.0:'`shuf -i 10001-49000 -n 1`'|g' ~/.config/syncthing/config.xml
	sed -i 's|<localAnnounceEnabled>true</localAnnounceEnabled>|<localAnnounceEnabled>false</localAnnounceEnabled>|g' ~/.config/syncthing/config.xml
	sed -i 's|<natEnabled>true</natEnabled>|<natEnabled>false</natEnabled>|g' ~/.config/syncthing/config.xml
	echo -e '\033[0;31m' IMPORTANT: now go set a password '\033[0m'

start:
	screen -dmS syncthing ~/bin/syncthing && make print-ip

print-ip:
	echo http://`hostname -f`:`sed -rn 's|.*<address>0.0.0.0:(.*)</address>.*|\1|p' ~/.config/syncthing/config.xml`

check:
	pgrep -laf ~/bin/syncthing

stop:
	pkill -f ~/bin/syncthing

restart: stop
	sleep 5 && screen -dmS syncthing ~/bin/syncthing && make print-ip

kill:
	pkill -9 -f ~/bin/syncthing

ensure:
	# call this from your crontab
	make check || make start

uninstall: kill
	rm -rf ~/.config/syncthing/ ~/bin/syncthing
	echo syncthing removed, synced files left alone

shell:
	screen -r syncthing


