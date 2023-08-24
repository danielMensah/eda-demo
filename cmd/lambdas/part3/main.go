package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/oklog/ulid/v2"
	"log"
	"strconv"
)

type bodyPayload struct {
	UserId    string `json:"userId"`
	Title     string `json:"title"`
	Completed string `json:"completed"`
	Part      string `json:"part"`
}

type service struct {
	database *dynamodb.Client
}

func main() {
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	svc := service{
		database: dynamodb.NewFromConfig(cfg),
	}

	lambda.Start(svc.handler)
}

func (s *service) handler(ctx context.Context, events []bodyPayload) error {
	for _, payload := range events {
		completed, _ := strconv.ParseBool(payload.Completed)

		if _, err := s.database.PutItem(ctx, &dynamodb.PutItemInput{
			TableName: aws.String("eda-demo-table"),
			Item: map[string]types.AttributeValue{
				"PK":        &types.AttributeValueMemberS{Value: fmt.Sprintf("user#%s", payload.UserId)},
				"SK":        &types.AttributeValueMemberS{Value: ulid.Make().String()},
				"title":     &types.AttributeValueMemberS{Value: payload.Title},
				"completed": &types.AttributeValueMemberBOOL{Value: completed},
				"part":      &types.AttributeValueMemberS{Value: payload.Part},
			},
		}); err != nil {
			log.Fatal(err)
		}
	}

	return nil
}
