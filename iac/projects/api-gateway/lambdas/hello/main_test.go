package main

import (
	"context"
	"encoding/json"
	"testing"
)

func TestHandlerInvoke(t *testing.T) {
	h := &Handler{}
	ctx := context.Background()
	b, err := h.Invoke(ctx, nil)
	if err != nil {
		t.Fatal(err)
	}
	var got response
	err = json.Unmarshal(b, &got)
	if err != nil {
		t.Fatal(err)
	}
	if got.Message != "Hello World!" {
		t.Fail()
	}
}
