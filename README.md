![Build Status](https://github.com/TheWicklowWolf/LidaTube/actions/workflows/main.yml/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/thewicklowwolf/lidatube.svg)

<p align="center">

![image](https://github.com/TheWicklowWolf/LidaTube/assets/111055425/69396f7a-af18-42a9-b1ea-0585b488bdec)


</p>

Web GUI for adding missing Lidarr albums to metube.


## Run using docker-compose

```yaml
version: "2.1"
services:
  huntorr:
    image: thewicklowwolf/lidatube:latest
    container_name: lidatube
    environment:
      - lidarr_address=http://192.168.1.2:8686
      - lidarr_api_key=1234567890
      - metube_address=http://192.168.1.2:8080
    ports:
      - 5000:5000
    restart: unless-stopped
```

---

<p align="center">


![image](https://github.com/TheWicklowWolf/LidaTube/assets/111055425/1167ea8a-a4c4-4229-a46f-f5832b6e5469)

</p>

---

https://hub.docker.com/r/thewicklowwolf/lidatube