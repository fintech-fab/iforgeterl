Iforiget.biz (web)
========================

**Установка (Ubuntu)**
------------------------

Установим необходимое ПО:

    sudo apt-get install erlang
    sudo apt-get install redis-server
    sudo apt-get install supervisior

Подготовка каталогов:

    sudo mkdir -p /var/www/iforget
    sudo mkdir -p /var/log/iforget
    cd /var/www/iforget
    sudo chown `whoami` .
  
Клонируем проект:

    git clone https://github.com/fintech-fab/iforgeterl.git .
    ./rebar get-deps
    ./rebar compile

Конфигурируем supevisor:

    sudo cp conf/supevisor.conf.dst /etc/supevisor/conf/iforget.conf
  
И запускаем:

    sudo supervisorctl reload
    sudo supervisorctl starti forget

**Запуск тестов**
------------------------
Запускаем коммандную строку:

	% > make

И выполняем команду:

	> eunit:test([auth, notice, groups]).


