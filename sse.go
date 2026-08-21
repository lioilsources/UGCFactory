package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
)

// Broker fans job/item events out to SSE clients (the Flutter app's queue
// screen). Slow clients get dropped rather than block the factory.
type Broker struct {
	mu      sync.Mutex
	clients map[chan []byte]struct{}
}

func NewBroker() *Broker { return &Broker{clients: map[chan []byte]struct{}{}} }

func (b *Broker) Publish(event string, payload any) {
	data, err := json.Marshal(map[string]any{"event": event, "data": payload})
	if err != nil {
		return
	}
	b.mu.Lock()
	defer b.mu.Unlock()
	for ch := range b.clients {
		select {
		case ch <- data:
		default: // klient nestiha - zahodit, at nezablokuje ostatni
		}
	}
}

func (b *Broker) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fl, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}
	ch := make(chan []byte, 16)
	b.mu.Lock()
	b.clients[ch] = struct{}{}
	b.mu.Unlock()
	defer func() {
		b.mu.Lock()
		delete(b.clients, ch)
		b.mu.Unlock()
	}()

	h := w.Header()
	h.Set("Content-Type", "text/event-stream")
	h.Set("Cache-Control", "no-cache")
	h.Set("Connection", "keep-alive")
	fmt.Fprintf(w, ": connected\n\n")
	fl.Flush()

	for {
		select {
		case <-r.Context().Done():
			return
		case msg := <-ch:
			fmt.Fprintf(w, "data: %s\n\n", msg)
			fl.Flush()
		}
	}
}
