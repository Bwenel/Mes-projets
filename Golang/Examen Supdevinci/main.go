package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {

	h1 := func(w http.ResponseWriter, _ *http.Request) {
		fmt.Println("/")
	}

	h2 := func(w http.ResponseWriter, _ *http.Request) {
		fmt.Println("/done")
	}

	h3 := func(w http.ResponseWriter, _ *http.Request) {
		fmt.Println("/add")
	}

	http.HandleFunc("/", h1)
	http.HandleFunc("/done", h2)
	http.HandleFunc("/add", h3)

	log.Fatal(http.ListenAndServe(":8000", nil))
}

var task []Task // On crée une variable tasks qui est une slice de notre struct Task

type Task []struct { // On définit  un type Task qui est une struct avec deux champs
	Description string
	Done        bool
}

type List struct { // On définit un type List qui est une struct avec l'ID et la Task
	ID   string
	Task string
}

func list(rw http.ResponseWriter, _ *http.Request) {
	task = []Task{
		{"Faire les courses", false},
		{"Payer les factures", false},
	}
	for id, i := range task { //On fait une boucle for afin de recuperer le status des tâches
		if !i.Done {
			list = append(list, i.Description) // Si une tache n'est pas terminée on l'affiche
			return
		}
	}
	rw.WriteHeader(http.StatusOK) // Si une tache est terminée on affiche un StatusOK
	return
}

// Exercice 3 fonction add
func add(rw http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost { // On vérifie que l'adresse de la méthode est bien POST en affichant une erreur de requette si la valeur est différent de celle attendu
		rw.WriteHeader(http.StatusBadRequest)
		return
	}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Printf("Error reading body: %v", err)
		http.Error(rw, "can't read body", http.StatusBadRequest)
		return
	}
}
