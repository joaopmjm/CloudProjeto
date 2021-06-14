package main

import (
    "encoding/json"
    "github.com/gorilla/mux"
    "log"
	"time"
    "net/http"
)

type Todo struct {
    Id           string    `json:"id,omitempty"`
    Title        string    `json:"firstname,omitempty"`
    Description  string    `json:"lastname,omitempty"`
    Updated      time.Time `json:"address,omitempty"`
}

var todos []Todo

func GetTodos(w http.ResponseWriter, r *http.Request) {
    json.NewEncoder(w).Encode(todos)
}

func GetTodo(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    for _, item := range todos {
        if item.Id == params["id"] {
            json.NewEncoder(w).Encode(item)
            return
        }
    }
    json.NewEncoder(w).Encode(&Todo{})
}

func NewTodo(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    var newTodo Todo
    _ = json.NewDecoder(r.Body).Decode(&newTodo)
    newTodo.Id = params["id"]
    todos = append(todos, newTodo)
    json.NewEncoder(w).Encode(todos)
}

func DeleteTodo(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    for index, item := range todos {
        if item.Id == params["id"] {
            todos = append(todos[:index], todos[index+1:]...)
            break
        }
        json.NewEncoder(w).Encode(todos)
    }
}

func main() {
    router := mux.NewRouter()    
	todos = append(todos, Todo{Id: "1", Title: "Sei la mano", Description: "Todos malucas", Updated: time.Now()})
	todos = append(todos, Todo{Id: "2", Title: "Louco mesmo", Description: "Todos loucas", Updated: time.Now()})
	router.HandleFunc("/todos", GetTodos).Methods("GET")
    router.HandleFunc("/todos/{id}", GetTodo).Methods("GET")
    router.HandleFunc("/todos/{id}", NewTodo).Methods("POST")
    router.HandleFunc("/todos/{id}", DeleteTodo).Methods("DELETE")    
	log.Fatal(http.ListenAndServe(":8001", router))
}