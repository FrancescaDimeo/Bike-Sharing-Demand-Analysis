require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
library(shiny)
library(tidyverse)
library(ggplot2)
library(httr)
library(scales)
library(leaflet)

source("model_prediction.R")

test_weather_data_generation<-function(){
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}

shinyServer(function(input, output){
  
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  
  city_weather_bike_df <- test_weather_data_generation()
  
  # 1. MAPPA
  output$city_bike_map <- renderLeaflet({
    if (input$city_dropdown == "All") {
      filtered_df <- city_weather_bike_df
    } else {
      filtered_df <- city_weather_bike_df %>%
        filter(CITY_ASCII == input$city_dropdown)
    }
    
    leaflet(filtered_df) %>%
      addTiles() %>%
      setView(lng = mean(filtered_df$LNG), lat = mean(filtered_df$LAT), 
              zoom = ifelse(input$city_dropdown == "All", 2, 9)) %>%
      addCircles(
        lng = ~LNG, lat = ~LAT, popup = ~LABEL, 
        radius = ~ifelse(BIKE_PREDICTION_LEVEL == 'small', 1000, 5000),
        color = ~ifelse(BIKE_PREDICTION_LEVEL == 'small', 'green', 'red')
      )
  })
  
  # 2. GRAFICO TEMPERATURA
  output$temp_line <- renderPlot({
    if (input$city_dropdown != "All") {
      plot_df <- city_weather_bike_df %>%
        filter(CITY_ASCII == input$city_dropdown)
      
      ggplot(plot_df, aes(x = FORECASTDATETIME, y = TEMPERATURE)) +
        geom_line(color = "blue", size = 1) +
        geom_point() +
        geom_text(aes(label = TEMPERATURE), vjust = -1) +
        labs(title = paste("Temperature Trend in", input$city_dropdown),
             x = "Time", y = "Temp (°C)") +
        theme_minimal()
    }
  })
  
  # 3. GRAFICO BICI
  output$bike_line <- renderPlot({
    if (input$city_dropdown != "All") {
      plot_df <- city_weather_bike_df %>%
        filter(CITY_ASCII == input$city_dropdown)
      
      ggplot(plot_df, aes(x = FORECASTDATETIME, y = BIKE_PREDICTION)) +
        geom_line(color = "red", linetype = "dashed") +
        geom_point() +
        labs(title = paste("Bike Demand Prediction in", input$city_dropdown),
             x = "Time", y = "Predicted Bikes") +
        theme_minimal()
    }
  })
  
  # 4. GRAFICO UMIDITÀ
  output$humidity_pred_chart <- renderPlot({
    if (input$city_dropdown != "All") {
      plot_df <- city_weather_bike_df %>%
        filter(CITY_ASCII == input$city_dropdown)
      
      ggplot(plot_df, aes(x = HUMIDITY, y = BIKE_PREDICTION)) +
        geom_point() +
        geom_smooth(method = "lm", formula = y ~ poly(x, 4), color = "green") +
        labs(title = paste("Humidity vs Bike Demand in", input$city_dropdown),
             x = "Humidity (%)", y = "Predicted Bikes") +
        theme_minimal()
    }
  })
  
  # 5. TESTO INTERATTIVO 
  output$bike_date_output <- renderText({
    if(!is.null(input$plot_click)) {
      paste0("Time: ", as.POSIXct(input$plot_click$x, origin="1970-01-01"),
             "\nPrediction: ", round(input$plot_click$y, 0))
    }
  })
  
})
