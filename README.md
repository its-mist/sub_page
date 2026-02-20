# Remnawave Subscription Page

Развёртывание страницы подписки Remnawave на отдельном сервере. SSL-сертификаты получаются автоматически через Let's Encrypt.

## Требования

- Чистый сервер с Ubuntu 22.04+
- Docker и Docker Compose
- Домен с A-записью, указывающей на IP сервера
- Свободные порты 80 и 443

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
| `CERTBOT_EMAIL` | Email для уведомлений Let's Encrypt (необязательно) | `admin@example.com` |
| `PANEL_URL` | Публичный URL панели Remnawave | `https://panel.example.com` |
| `REMNAWAVE_API_TOKEN` | API-токен из панели (Dashboard → Settings → API Tokens) | |
| `APP_PORT` | Внутренний порт (по умолчанию 3010) | `3010` |
| `META_TITLE` | Заголовок страницы | `Remnawave Subscription` |
| `META_DESCRIPTION` | Описание страницы | `page` |

### 4. Получить SSL-сертификат (только при первом деплое)

```bash
docker compose --profile init up certbot
```

Certbot получит сертификат через Let's Encrypt. Порты 80 и 443 должны быть свободны.

### 5. Запустить

```bash
docker compose up -d
```

Страница подписки будет доступна по `https://ВАШ_ДОМЕН`.

### 6. Проверить

```bash
docker compose ps
docker compose logs -f
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

## Продление сертификата

Сертификаты Let's Encrypt действуют 90 дней. Для продления:

```bash
cd /opt/sub_page
./scripts/renew-certs.sh
```

Или добавить в crontab для автопродления:

```bash
crontab -e
# Добавить строку:
0 3 1 */2 * cd /opt/sub_page && ./scripts/renew-certs.sh >> /var/log/certbot-renew.log 2>&1
```

## Обновление

```bash
docker compose pull
docker compose up -d
```
