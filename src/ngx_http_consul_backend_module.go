// package name: ngx_http_consul_backend_module
package main

import (
	"C"

	"context"
	"fmt"
	"log"
	"math/rand"
	"strings"
	"time"

	"github.com/hashicorp/consul/api"
)

var (
	// client is the underlying API client.
	client *api.Client

	// resultNoBackend is the result returned when there is no backend.
	resultNoBackend = C.CString("")
)

const (
	// ctxTimeout is the default context timeout.
	ctxTimeout = 5 * time.Second

	// serviceTagSep is the separator between service names and tags.
	serviceTagSep = "@"
)

// main is required for the file to compile to an object.
func main() {}

// setup the consul client
func init() {
//	cfg :=api.DefaultConfig()
//	cfg.Address="192.168.61.70:8500"
//	c, err := api.NewClient(cfg)
//	if err != nil {
//		log.Fatal(err)
//	}
//	
//	client = c
}

//export LookupBackend
func LookupBackend(svc *C.char) *C.char {
	
	log.Printf("[debug] consul:config %s",C.GoString(svc))
	
	service,tag, host := extractService(C.GoString(svc))

	log.Printf("[debug] consul: lookup service=%s, tag=%s,host=%s", service, tag,host)

	list, err := backends(service, tag, host)
	if err != nil {
		log.Fatal(err)
	}
	if len(list) < 1 {
		return resultNoBackend
	}

	i := rand.Intn(len(list))

	log.Printf("[debug] consul: returned %d services", len(list))

	return C.CString(list[i])
}

// extractService tags a string in the form "tag.name" and separates it into
// the service and tag name parts.
func extractService(s string) (service, tag, host string) {
	split := strings.SplitN(s, serviceTagSep, 3)

	switch {
	case len(split) == 0:
	case len(split) == 1:
		service = split[0]
	default:
		tag, service,host = split[0], split[1],split[2]
	}

	return
}

// backends collects the list of healthy backends for the given service name and tag,
// and returns
func backends(name, tag ,host string) ([]string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), ctxTimeout)
	defer cancel()

	q := &api.QueryOptions{
		AllowStale: true,
	}
	q = q.WithContext(ctx)

	//init client
	cfg :=api.DefaultConfig()
        cfg.Address=host
        c, err := api.NewClient(cfg)
        if err != nil {
                log.Fatal(err)
        }

        client = c
	
	services, _, err := client.Health().Service(name, tag, true, q)
	if err != nil {
		return nil, fmt.Errorf("failed to lookup service %q: %s", name, err)
	}

	addrs := make([]string, len(services))
	for i, s := range services {
		addr := s.Service.Address
		if addr == "" {
			addr = s.Node.Address
		}
		addrs[i] = fmt.Sprintf("%s:%d", addr, s.Service.Port)
	}

	return addrs, nil
}
