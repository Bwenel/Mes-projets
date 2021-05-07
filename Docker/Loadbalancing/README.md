Comment l'utiliser ?

1. Tout d'abord monter les images :

docker build -t myhaproxy .

docker build -t nginx1 . 

docker build -t nginx2 .

2. Créer le réseau 

docker network create web

3. Démarrer les containers

docker run -d --net web --name web1 -v /home/USER/nginx1/index.html.web1:/usr/share/nginx/html/index.html nginx

docker run -d --net web --name web2 -v /home/USER/nginx2/index.html.web2:/usr/share/nginx/html/index.html nginx

docker run -d --net web --name haproxy -p 80:80 -v /home/USER/myhaproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg haproxy:1.7

4. Effectuer un test

curl 0