# Remnawave Subscription Page

Развёртывание страницы подписки Remnawave на отдельном сервере.

## Требования

- Чистый сервер с Ubuntu 22.04+
- Docker и Docker Compose
- Домен с A-записью, указывающей на IP сервера

## Развёртывание

### 1. Установить Docker

```bash
curl -fsSL https://get.docker.com | sh
```

### 2. Клонировать репозиторий

```bash
git clone <repo-url> /opt/sub_page
cd /opt/sub_page
```

### 3. Настроить переменные окружения

```bash
cp .env.example .env
nano .env
```

Заполнить значения:

| Переменная | Описание | Пример |
|---|---|---|
| `SUB_DOMAIN` | Домен страницы подписки | `sub.example.com` |
| `PANEL_URL` | Публичный URL панели Remnawave | `https://panel.example.com` |
| `APP_PORT` | Внутренний порт (по умолчанию 3010) | `3010` |
| `META_TITLE` | Заголовок страницы | `Remnawave Subscription` |
| `META_DESCRIPTION` | Описание страницы | `page` |

### 4. Установить Nginx и получить SSL-сертификат

```bash
apt install -y nginx certbot python3-certbot-nginx

# Получить сертификат (DNS уже должен указывать на этот сервер)
certbot certonly --standalone -d ВАШ_ДОМЕН
```

### 5. Настроить Nginx

```bash
# Скопировать шаблон конфига
cp nginx.conf.example /etc/nginx/sites-available/sub_page

# Заменить SUB_DOMAIN на ваш домен
sed -i 's/SUB_DOMAIN/ВАШ_ДОМЕН/g' /etc/nginx/sites-available/sub_page

# Включить сайт
ln -s /etc/nginx/sites-available/sub_page /etc/nginx/sites-enabled/

# Удалить дефолтный сайт если мешает
rm -f /etc/nginx/sites-enabled/default

# Проверить конфиг и перезагрузить
nginx -t && systemctl reload nginx
```

### 6. Запустить сервис

```bash
docker compose up -d
```

### 7. Проверить

```bash
# Статус контейнера
docker compose ps

# Логи
docker compose logs -f

# Проверить HTTPS
curl -I https://ВАШ_ДОМЕН
```

## Что изменить на сервере с панелью

На сервере, где установлена панель Remnawave, обновить `.env`, чтобы ссылки подписок вели на новый домен:

```bash
# Отредактировать /opt/remnawave/.env
# Изменить строку:
SUB_PUBLIC_DOMAIN=sub.новый-домен.com

# Перезапустить бэкенд:
cd /opt/remnawave
docker compose restart remnawave
```

После этого панель будет генерировать ссылки подписок с новым доменом.

## Автопродление SSL

Certbot настраивает автопродление автоматически. Проверить:

```bash
certbot renew --dry-run
```

## Обновление

```bash
docker compose pull
docker compose up -d
```
