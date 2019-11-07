package main

import (
	"math/rand"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

//InputEvent is a struct that contains the fields expected to come in from the Step Function
type InputEvent struct {
	Ingredients []string
}

//OutputEvent is a struct that contains the fields expected to go back out to the Step Function
type OutputEvent struct {
	CookieDough CookieDough
	EatDough    bool `json:"eatDough"`
}

//DryMixture is a struct that contains the ingredients in a dry mix
type DryMixture struct {
	Flour        bool
	BakingPowder bool
	Salt         bool
}

//WetMixture is a struct that contains the ingredients in a wet mix
type WetMixture struct {
	Egg     bool
	Vanilla bool
	Butter  bool
	Sugar   bool
}

//CookieDough is a struct that combines the dry and wet ingredients
type CookieDough struct {
	DryMixture DryMixture
	WetMixture WetMixture
}

var dryMixture DryMixture
var wetMixture WetMixture

func handler(e InputEvent) (OutputEvent, error) {
	for _, ingredient := range e.Ingredients {
		if ingredient == "flour" || ingredient == "baking powder" || ingredient == "salt" {
			mixDry(ingredient)
		} else {
			mixWet(ingredient)
		}
	}
	return OutputEvent{CookieDough: CookieDough{dryMixture, wetMixture}, EatDough: eatDough()}, nil
}

//eatDough is a function that randomly returns true or false to decide whether to eat or bake cookie dough
func eatDough() bool {
	rand.Seed(time.Now().UnixNano())
	return rand.Float32() < 0.5
}

func mixDry(ingredient string) {
	switch ingredient {
	case "flour":
		dryMixture.Flour = true
	case "baking powder":
		dryMixture.BakingPowder = true
	case "salt":
		dryMixture.Salt = true

	}
}

func mixWet(ingredient string) {
	switch ingredient {
	case "egg":
		wetMixture.Egg = true
	case "vanilla":
		wetMixture.Vanilla = true
	case "butter":
		wetMixture.Butter = true
	case "sugar":
		wetMixture.Sugar = true
	}
}

func main() {
	lambda.Start(handler)
}
