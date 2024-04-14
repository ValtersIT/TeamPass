Hello,<br>
I created this project because I wanted to make a better Docker image for the TeamPass project. The Docker image is written from 0 and the code is published here in this GitHub repository, but the TeamPass project after the 1 run is automatically downloaded from the GitHub official repository.
<br><br>
<b>About TeamPass:</b><br>
TeamPass is an open-source password storage solution, that can be hosted on any Linux server including shared hosting servers or even Docker containers. Thanks to TeamPass you can keep your passwords secure and in your data center, if you need to generate some passwords, then using TeamPass you can do that in several difficulty levels. Also if you work in a team, then it is easy to share passwords among team members and keep track of who has accessed, changed, and deleted what kind of password. Also for organizations you can have several departments where only that department user group can access passwords that are meant for them and for each department you can even assign a manager. Teampass can be connected with LDAP and OpenLDAP. This is a great secure way of storing, sharing, and organizing your passwords + it has also a knowledge base that not only encrypts passwords but also attachments with an additional layer of security more information you can find in my video: https://youtu.be/eXieWAIsGzc from my point of view it is a great tool and best part it is free to use.
<br><br>
<b>Installation:</b><br>
If you don't have your own Docker network and would want to create one, then you can watch my YouTube shorts https://youtube.com/shorts/bAfyib3TuVM?feature=share
<br><br>
TeamPass Docker container can work without any custom Docker network, it can be used with the default docker setup. 
<br><br>
But if you also want to use nginx reverse proxy with Let's Encrypt then you can watch the tutorial here: https://youtube.com/shorts/Mqv2V16I5Q4?feature=share - This is not mandatory.
<br><br>
In my tutorial, I'm using MySQL root as a database owner and administrator, but for proper setup, I suggest creating a separate user, that can only connect to the TeamPass database more info: https://www.valters.eu/docker-mysql-container-setup-and-basic-configuration/
<br><br>
To run the TeamPass without MySQL container, execute the following:<br>
Replace the domain name from mysubdomain.domain.com with your domain or subdomain and also replace somemail@somedomainmail.com with your e-mail where Let's encrypt if you are using it to send information reminders about certificate expiration
<br>
```
docker run --name mysubdomain.domain.com --restart always --publish-all -p 828:80 -p 428:443 --hostname=mysubdomain.domain.com -e VIRTUAL_HOST=mysubdomain.domain.com -e LETSENCRYPT_EMAIL=somemail@somedomainmail.com -e LETSENCRYPT_HOST=mysubdomain.domain.com -d valterseu/teampass
```
<br><br>
To Run the TeamPass with MySQL use this docker-composer.yml ( How to use it can be seen in my YouTube video: https://youtu.be/eXieWAIsGzc 
<br>
```
version: '2'

services:
#MySQL Container
  mysql:
# Downloads latest MySQL image from Docker Hub
    image: mysql:latest
# Network if you have created one for your containers if not leave commented out
#    networks:
#      - valterseu
# Always restart the container on failure or when VPS/Server is restarted auto start docker container
    restart: always
# Additional commands for Native password and encoding to support all the characters
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --default-authentication-plugin=mysql_native_password
# Mount MySQL directory that contains DB files with your linux folder.
    volumes:
      - /srv/docker/mysql:/var/lib/mysql
# MySQL root main admin password please choose a strong password, don't use this demo password!
    environment:
      - MYSQL_ROOT_PASSWORD=ThisIsADemoPasswordNot@Real12454

# TeamPass Docker container
  teampass:
# Downloads latest MySQL image from Docker Hub
    image: valterseu/teampass
# Network if you have created one for your containers if not leave commented out
#    networks:
#      - valterseu
# Always restart the container on failure or when VPS/Server is restarted auto start docker container
    restart: always
# Change mysubdomain.domain.com to your domain or subdomain
    command: --hostname=mysubdomain.domain.com
    ports:
      - 829:80
      - 429:443
# Links mean that the TeamPass container is dependent on the MySQL container, if the MySQL container doesn't work, then TeamPass will also not start
    links:
      - mysql
# Replace the domain name from mysubdomain.domain.com with your domain or subdomain and also replace somemail@somedomainmail.com with your e-mail where Let's encrypt if you are using # it to send information reminders about certificate expiration
    environment:
      - VIRTUAL_HOST=mysubdomain.domain.com
      - LETSENCRYPT_EMAIL=somemail@somedomainmail.com
      - LETSENCRYPT_HOST=mysubdomain.domain.com

#Network if you have created one for your containers if not leave commented out
#networks:
#  valterseu:
#    external: true
```
<br><br>
Follow for more interesting CyberSecurity, IT, Product/service review<br>
YouTube: https://www.youtube.com/@valters_eu <br>
Twitter: https://twitter.com/valters_eu <br>
Website: https://www.valters.eu/ <br>
Docker Hub image: https://hub.docker.com/r/valterseu/teampass <br>

