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
}


func ReplaceLocation(url_len int,url,loc *C.char,path string) string {
	
	sUrl :=C.GoString(url)
	sLoc :=C.GoString(loc)

	sUrl = sUrl[0:url_len]

	if len(sLoc)>0 {
		sUrl = strings.Replace(sUrl,sLoc,path,1)
	}

	return sUrl
}

//export LookupBackend
func LookupBackend(uri_len int,uri,loc,svc *C.char) *C.char {
	
	log.Printf("[debug] consul:config %s",C.GoString(svc))
	
	service,tag, host,newPath := extractService(C.GoString(svc))

	log.Printf("[debug] consul: lookup service=%s, tag=%s,host=%s,url=%s,loc=%s,uri_len=%d newPath=%s", service, tag,host,C.GoString(uri),
		C.GoString(loc),uri_len,newPath)

	url := ReplaceLocation(uri_len,uri,loc,newPath)

	list, err := backends(service, tag, host)

	if err != nil {
		log.Fatal(err)
	}
	if len(list) < 1 {
		log.Printf("[error] no backend for %s",C.GoString(svc))
		return resultNoBackend
	}

	i := rand.Intn(len(list))

	log.Printf("[debug] consul: returned %d services", len(list))

	upstream :=strings.Join([]string{list[i],url},"")

	return C.CString(upstream)
}

// extractService tags a string in the form "tag.name" and separates it into
// the service and tag name parts.
func extractService(s string) (service, tag, host,newPath string) {
	split := strings.SplitN(s, serviceTagSep, 4)

	switch {
	case len(split) == 0:
	case len(split) == 1:
		service = split[0]
	default:
		tag, service,host,newPath= split[0], split[1],split[2],split[3]
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
