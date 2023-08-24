package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	lmb "github.com/aws/aws-sdk-go-v2/service/lambda"
	lmbTypes "github.com/aws/aws-sdk-go-v2/service/lambda/types"
	"io"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/lambda"
)

type bodyPayload struct {
	UserId    int    `json:"userId"`
	Title     string `json:"title"`
	Completed bool   `json:"completed"`
}

type service struct {
	database *dynamodb.Client
	lambda   *lmb.Client
}

func main() {
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	svc := service{
		database: dynamodb.NewFromConfig(cfg),
		lambda:   lmb.NewFromConfig(cfg),
	}

	lambda.Start(svc.handler)
}

func (s *service) handler(ctx context.Context, cloudWatchEvent events.CloudWatchEvent) error {
	fmt.Printf("event: %v\n", cloudWatchEvent)

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

	payload := bodyPayload{}
	if err = json.Unmarshal(body, &payload); err != nil {
		log.Fatal(err)
	}

	// store enriched data in DynamoDB
	if _, err = s.database.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: aws.String("eda-demo-table"),
		Item: map[string]types.AttributeValue{
			"PK":        &types.AttributeValueMemberS{Value: fmt.Sprintf("user#%d", payload.UserId)},
			"SK":        &types.AttributeValueMemberS{Value: cloudWatchEvent.ID},
			"title":     &types.AttributeValueMemberS{Value: payload.Title},
			"completed": &types.AttributeValueMemberBOOL{Value: payload.Completed},
			"part":      &types.AttributeValueMemberS{Value: cloudWatchEvent.DetailType},
		},
	}); err != nil {
		log.Fatal(err)
	}

	// invoke processor lambda
	if _, err = s.lambda.Invoke(ctx, &lmb.InvokeInput{
		FunctionName:   aws.String("eda-demo-processor"),
		InvocationType: lmbTypes.InvocationTypeEvent,
		Payload:        body,
	}); err != nil {
		log.Fatal(err)
	}

	return nil
}
