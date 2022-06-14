package main

import (
	"log"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go/pkg/handler"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go/pkg/repository"
	"github.com/eugenia-ponomarenko/ToDo-REST-Go/pkg/service"
)

func main() {
	repos := repository.NewRepository()
	services := service.NewService(repos)
	handlers := handler.NewHandler(services)

	srv := new(todo.Server)
	if err := srv.Run("8000", handlers.InitRoutes()); err != nil {
		log.Fatalf("error occured while running http server: %s", err.Error())
	}
}
