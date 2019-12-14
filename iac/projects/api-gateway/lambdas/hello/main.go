package main

import (
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// Handler is a lambda handler.
type Handler struct{}

// Invoke implements lambda.Handler.
func (h *Handler) Invoke(ctx context.Context, payload []byte) ([]byte, error) {
	//	lctx, _ := lambdacontext.FromContext(ctx)
	resp := events.APIGatewayProxyResponse{
		StatusCode:      200,
		IsBase64Encoded: false,
		Headers:         map[string]string{"Content-Type": "application/json"},
		Body:            `{"message": "Hello World!"}`,
	}
	b, err := json.Marshal(resp)
	if err != nil {
		return nil, err
	}
	return b, nil
}

func main() {
	lambda.StartHandler(&Handler{})
}
