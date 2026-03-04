require(leaflet)
library(leaflet)
library(shiny)

library(shiny)
library(leaflet)

shinyUI(
  fluidPage(padding=5,
            titlePanel("Bike-sharing demand prediction app"), 
            
            sidebarLayout(
              # Pannello Laterale (Input e Grafici)
              sidebarPanel(
                selectInput(inputId = "city_dropdown", 
                            label = "Select City:", 
                            choices = c("All", "Seoul", "New York", "Paris", "Suzhou", "London")),
               
                plotOutput("temp_line"),
                plotOutput("bike_line", click = "plot_click"),
                plotOutput("humidity_pred_chart"),
                verbatimTextOutput("bike_date_output")
                
              ),
              
              #TASK 1
              mainPanel(
                leafletOutput("city_bike_map", height = "1000px")
              )
            ) # Chiusura sidebarLayout
  ) # Chiusura fluidPage
) # Chiusura shinyUI