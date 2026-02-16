package proxy

import (
	"bytes"
	"io"
	"log"
	"net/http"
	"net/url"
)

type ServiceProxy struct {
	authServiceURL string
}

func NewServiceProxy(authServiceURL string) *ServiceProxy {
	return &ServiceProxy{
		authServiceURL: authServiceURL,
	}
}

func (sp *ServiceProxy) AuthProxy() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		sp.proxyRequest(w, r, sp.authServiceURL)
	})
}

func (sp *ServiceProxy) proxyRequest(w http.ResponseWriter, r *http.Request, targetURL string) {
	// Parse target URL
	target, err := url.Parse(targetURL)
	if err != nil {
		log.Printf("Error parsing target URL: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Create new request URL
	proxyURL := target.String() + r.URL.Path
	if r.URL.RawQuery != "" {
		proxyURL += "?" + r.URL.RawQuery
	}

	// Read request body
	var bodyBytes []byte
	if r.Body != nil {
		bodyBytes, err = io.ReadAll(r.Body)
		if err != nil {
			log.Printf("Error reading request body: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
		r.Body.Close()
	}

	// Create new request
	proxyReq, err := http.NewRequestWithContext(r.Context(), r.Method, proxyURL, bytes.NewReader(bodyBytes))
	if err != nil {
		log.Printf("Error creating proxy request: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Copy headers
	for key, values := range r.Header {
		for _, value := range values {
			proxyReq.Header.Add(key, value)
		}
	}

	// Make request to target service
	client := &http.Client{}
	resp, err := client.Do(proxyReq)
	if err != nil {
		log.Printf("Error forwarding request: %v", err)
		http.Error(w, "Service unavailable", http.StatusServiceUnavailable)
		return
	}
	defer resp.Body.Close()

	// Copy response headers
	for key, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(key, value)
		}
	}

	// Copy status code
	w.WriteHeader(resp.StatusCode)

	// Copy response body
	if _, err := io.Copy(w, resp.Body); err != nil {
		log.Printf("Error copying response body: %v", err)
	}
}
