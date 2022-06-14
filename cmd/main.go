package main

import (
	"log"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go/pkg/handler"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go/pkg/repository"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go/pkg/service"
	"github.com/spf13/viper"
)

func main() {
	if err := initConfig(); err != nil {
		log.Fatalf("error initializing configs: %s", err.Error())
	}

	repos := repository.NewRepository()
	services := service.NewService(repos)
	handlers := handler.NewHandler(services)

	srv := new(todo.Server)
	if err := srv.Run(viper.GetString("8000"), handlers.InitRoutes()); err != nil {
		log.Fatalf("error occured while running http server: %s", err.Error())
	}	
}

func initConfig() error {
	viper.AddConfigPath("configs")
	viper.SetConfigName("config")
	return viper.ReadInConfig()
}
