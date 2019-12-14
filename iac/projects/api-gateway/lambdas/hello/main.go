package main

import (
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/lambda"
)

type response struct {
	Message string `json:"message"`
}

// Handler is a lambda handler.
type Handler struct{}

// Invoke implements lambda.Handler.
func (h *Handler) Invoke(ctx context.Context, payload []byte) ([]byte, error) {
	//	lctx, _ := lambdacontext.FromContext(ctx)
	resp := response{
		Message: "Hello World!",
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
