# FF14 Stats

This repo contains the Terraform code, RShiny code, and Dockerfiles for the data viz for Final Fantasy XIV combat logs.


To access the RShiny app navigate to https://ff14-viz.njax.org and click around!

## Local Development

Boot the MySQL container

```
docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=${FF14_PASSWORD} -e MYSQL_DATABASE=myDatabase -p 3306:3306 -d mysql:8 --sql-mode=""
```

## ACT Configuration

Replace `YOUR_PASSWORD` with `${FF14_PASSWORD}`

```
DRIVER={MySQL ODBC 8.0 Unicode Driver};SERVER=127.0.0.1;PORT=3306;DATABASE=myDatabase;USER=root;PASSWORD=YOUR_PASSWORD;OPTION=3; 
```

## To build Docker Container (for debugging)

```
docker build . -t ff14-stats

docker run -p 8888:8888 ff14-stats

```

## For running with docker compose

```
docker compose up
```

To reset the containers run:
```
docker compose down
docker volume rm ff14-stats_db_data
```

