# bash_installer
Web Server Action Script on Ubuntu

В данному проекті збираю скрипти для зручного лаштування Web Server.

1. Для використання скачайте й розпакуйте скрипти
```
sudo apt-get install -y unzip wget && wget https://github.com/YmNIK13/bash_installer/archive/refs/heads/master.zip && unzip master.zip && mv bash_installer-master/ install && rm master.zip && cd install
```
2. Видаліть не потрібне ПО (за назвою файла)

3. Відкрийте скрипт `nano start.sh`

4. Встановіть чи видаліть змінні

```
SSH_PORT - якщо хочете змінити порт, обовязково пропишіть ваш ключ доступу до серверу, так як вхід через пароль буде закрито

DOMAIN -  домен який буде привязаний до серверу (буде прописано в конфігі NGinx)
PUBLIC_PATH - папка де буде знаходитись точка входу  (буде прописано в конфігі NGinx)

PHP_V=8.1 - версія PHP

# дані доступу для MySQL, якщо не встановлюєте її, можна не запонювати
MYS_NAME_DB 
MYS_NAME_USER=
MYS_PASS_USER=


# дані доступу для PostgrSQL, якщо не встановлюєте її, можна не запонювати
PGS_NAME_DB=
PGS_NAME_USER=
PGS_NAME_PASS=
```
5. Збережіть зміни `Ctrl + O`

6. Запустіть скрипт `bash start.sh`
