package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"

	"github.com/streadway/amqp"
	_ "github.com/lib/pq"
)

type PurchaseRequest struct {
	Tenant    string `json:"tenant"`
	ProductId int    `json:"product_id"`
}

func main() {
	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
	failOnError(err, "Failed to connect to RabbitMQ")
	defer conn.Close()

	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"purchase_requests",
		true,
		false,
		false,
		false,
		nil,
	)
	failOnError(err, "Failed to declare queue")

	msgs, err := ch.Consume(
		q.Name,
		"",
		true,
		false,
		false,
		false,
		nil,
	)
	failOnError(err, "Failed to register consumer")

	log.Println("Waiting for purchase requests...")

	forever := make(chan bool)

	go func() {
		for d := range msgs {
			var request PurchaseRequest
			if err := json.Unmarshal(d.Body, &request); err != nil {
				log.Printf("Error decoding JSON: %s", err)
				continue
			}

			log.Printf("Processing purchase: Tenant=%s, ProductID=%d\n", request.Tenant, request.ProductId)

			dbname := request.Tenant
			connStr := fmt.Sprintf("host=localhost port=5432 user=postgres password=password dbname=%s sslmode=disable", dbname)
			db, err := sql.Open("postgres", connStr)
			if err != nil {
				log.Printf("Failed to connect to DB %s: %s", dbname, err)
				continue
			}
			defer db.Close()

			res, err := db.Exec(`UPDATE products SET sold_qty = sold_qty + 1 WHERE id = $1`, request.ProductId)
			if err != nil {
				log.Printf("DB update error: %s", err)
				continue
			}
			rowsAffected, _ := res.RowsAffected()
			if rowsAffected == 0 {
				log.Printf("Product %d not found in tenant DB %s", request.ProductId, dbname)
			} else {
				log.Printf("Product %d sold_qty incremented for tenant %s", request.ProductId, dbname)
			}

			if d.ReplyTo != "" {
				response := "payment processed"
				err = ch.Publish(
					"",
					d.ReplyTo,
					false,
					false,
					amqp.Publishing{
						ContentType:   "text/plain",
						CorrelationId: d.CorrelationId,
						Body:          []byte(response),
					},
				)
				if err != nil {
					log.Printf("Failed to send response: %s", err)
				} else {
					log.Println("Sent acknowledgment: payment processed")
				}
			}
		}
	}()

	<-forever
}

func failOnError(err error, msg string) {
	if err != nil {
		log.Fatalf("%s: %s", msg, err)
	}
}
