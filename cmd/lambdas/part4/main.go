package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"io"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/lambda"
)

type service struct {
}

func main() {
	svc := service{}
	lambda.Start(svc.handler)
}

func (s *service) handler(ctx context.Context, event events.SQSEvent) error {
	bodies := make([]interface{}, 0)
	for _, record := range event.Records {
		bodies = append(bodies, record.Body)
	}

	fmt.Printf("sqs event: %v\n", bodies)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, "https://jsonplaceholder.typicode.com/todos/1", nil)
	if err != nil {
		log.Fatal(err)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	fmt.Printf("data: %v\n", string(body))
	return nil
}
