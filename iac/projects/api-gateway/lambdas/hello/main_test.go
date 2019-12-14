package main

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

func TestHandlerInvoke(t *testing.T) {
	h := &Handler{}
	ctx := context.Background()
	b, err := h.Invoke(ctx, nil)
	if err != nil {
		t.Fatal(err)
	}
	var got events.APIGatewayProxyResponse
	err = json.Unmarshal(b, &got)
	if err != nil {
		t.Fatal(err)
	}
	if got.Body != `{"message": "Hello World!"}` {
		t.Fail()
	}
}
