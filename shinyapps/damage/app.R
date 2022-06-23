library(shiny)
library(RMariaDB)
library(tidyverse)
library(lubridate)

options(shiny.host = '0.0.0.0')
options(shiny.port = 8888)

ff14_password <- Sys.getenv('FF14_PASSWORD')
user <- 'root'
dbname <- 'myDatabase'

con <- dbConnect(RMariaDB::MariaDB()
    , user = user
    , password = ff14_password
    , host='db'
    , port='3306'
    , dbname=dbname)

allies <- tbl(con, "combatant_table") %>%
    filter(ally == "T") %>%
    pull(name)

top_attackers <- tbl(con, "swing_table") %>% 
    filter(damage > 0) %>% 
    as.data.frame() %>% 
    mutate(stime = floor_date(stime, unit = "seconds")) %>%
    filter(stime < '2022-05-25') %>%
    filter(attacker %in% allies) %>%
    group_by(attacker) %>% 
    summarise(damage = sum(damage, na.rm = TRUE)) %>%
    ungroup() %>% 
    as.data.frame() %>%
    arrange(-damage) %>% 
    head(10)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("FF14 Test"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        #sidebarPanel(
        #    sliderInput("number",
        #                "Number of combatants:",
        #                min = 1,
        #                max = 50,
        #                value = 4)
        #),
        
        radioButtons(
            inputId = 'attacker',
            label = 'Attacker',
            choices = top_attackers$attacker,
            selected = top_attackers$attacker[1]
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("timePlot"), plotOutput("damagePlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

    output$damagePlot <- renderPlot({
        fig <- tbl(con, "swing_table") %>% 
            filter(damage > 0) %>% 
            as.data.frame() %>% 
            filter(attacker %in% allies) %>%
            mutate(stime = floor_date(stime, unit = "seconds")) %>%
            filter(stime < '2022-05-25') %>%
            group_by(attacker) %>% 
            summarise(damage = sum(damage, na.rm = TRUE)) %>%
            ungroup() %>% 
            as.data.frame() %>%
            arrange(-damage) %>% 
            head(8) %>%
            mutate(damage = as.integer(damage)) %>%
            mutate(attacker = factor(attacker, levels=attacker)) %>% 
                ggplot(aes(x=attacker, y=damage)) +
                    geom_bar(stat="identity", fill='#1F77B4') + theme_linedraw()
        print(fig)
    })
    
    output$timePlot <- renderPlot({
        fig <- tbl(con, "swing_table") %>% 
            filter(damage > 0) %>% 
            as.data.frame() %>% 
            filter(attacker == input$attacker) %>%
            mutate(stime = floor_date(stime, unit = "seconds")) %>%
            filter(stime < '2022-05-25') %>%
            group_by(stime) %>% 
            summarise(damage = sum(damage, na.rm = TRUE)) %>%
            ungroup() %>%
            mutate(damage = as.integer(damage)) %>%
            ggplot(aes(x=stime, y=damage))  +
                geom_bar(stat="identity", fill='#1F77B4') + theme_linedraw()
        print(fig)
    })

    session$onSessionEnded(function() {
        dbDisconnect(con)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
