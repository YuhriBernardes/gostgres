package main

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

type Person struct{
	gorm.Model
	Name string `gorm:"not null"`
	Age int
}

type PostgresConfig struct {
	Host string
	Port int
	DbName string
	User string
	Password string
}

func connect (config PostgresConfig) *gorm.DB {
	configString :=
		fmt.Sprintf("host=%s port=%d dbname=%s user=%s password=%s sslmode=disabled",
			config.Host,
			config.Port,
			config.DbName,
			config.User,
			config.Password)

	db, err := gorm.Open("postgres", configString)
	if err != nil {
		fmt.Println(err)
		fmt.Println(configString)
		panic("Failed to connect to database")
	}

	return db
}

func loadEnvs(){
	err := godotenv.Load()
	if err != nil {
		fmt.Println(err)
		panic("Failed to load .env file")
	}
}

func getConfig() PostgresConfig{
	dbPort, _ := strconv.Atoi(os.Getenv("DB_PORT"))
	return PostgresConfig{os.Getenv("DB_HOST"), dbPort, os.Getenv("DB_NAME"), os.Getenv("DB_USER"), os.Getenv("DB_PASS")}
}

func printPerson(person Person){
		fmt.Printf("ID: %02d | Name: %s | Age: %02d | Created At: %s\n", person.ID, person.Name, person.Age, person.CreatedAt.Format("2006-01-02 15:04:05"))
}

func printPersons(persons []Person){
	for _, p := range persons {
		printPerson(p)
	}
}

func main() {
	loadEnvs()

	config := getConfig()

	db := connect(config)

	defer db.Close()

	db.AutoMigrate(&Person{})

	myPerson := Person{Name: "Yuhri", Age: 23}

	fmt.Println("Creating new person:")
	printPerson(myPerson)

	db.Create(&myPerson)

	var found []Person

	db.Find(&found)

	fmt.Println("\nFound Person(s):")
	printPersons(found)

	for _, p := range found {
		p.Age ++
		db.Save(&p)
	}

	db.Find(&found)

	fmt.Println("\nUpdated Person(s):")
	printPersons(found)

	fmt.Println("\nDeleating Person(s)")
	db.Delete(&Person{})

}
