# Используем только Nginx
FROM nginx:alpine

# Удаляем дефолтный конфиг
RUN rm /etc/nginx/conf.d/default.conf

# Копируем наш конфиг Nginx
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf

# Копируем УЖЕ ГОТОВУЮ папку build/web из репозитория внутрь Nginx
COPY build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]