FROM rocker/shiny-verse

RUN install2.r RMariaDB lubridate

ADD shinyapps/ /shinyapps

WORKDIR /shinyapps

CMD [ "Rscript", "-e", "library(shiny);runApp('damage')" ]
