package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
)

// Broker fans job/item/character events out to SSE clients (the studio app's
// queue screen, the FC app's progress stepper). Slow clients get dropped
// rather than block the factory.
//
// A client either watches everything (the studio) or one topic — a character
// id — so the phone streaming one generation is not woken by the whole farm.
type Broker struct {
	mu      sync.Mutex
	clients map[chan []byte]string // kanal -> topic ("" = vse)
}

func NewBroker() *Broker { return &Broker{clients: map[chan []byte]string{}} }

func (b *Broker) Publish(event string, payload any) { b.PublishTopic("", event, payload) }

// PublishTopic reaches the global watchers and the ones on this topic.
func (b *Broker) PublishTopic(topic, event string, payload any) {
	data, err := json.Marshal(map[string]any{"event": event, "data": payload})
	if err != nil {
		return
	}
	b.mu.Lock()
	defer b.mu.Unlock()
	for ch, want := range b.clients {
		if want != "" && want != topic {
			continue
		}
		select {
		case ch <- data:
		default: // klient nestiha - zahodit, at nezablokuje ostatni
		}
	}
}

func (b *Broker) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	b.ServeTopic(w, r, "")
}

func (b *Broker) ServeTopic(w http.ResponseWriter, r *http.Request, topic string) {
	fl, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}
	ch := make(chan []byte, 16)
	b.mu.Lock()
	b.clients[ch] = topic
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
