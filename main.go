// Copyright ©2022-2024 Mr MXF   info@mrmxf.com
// BSD-3-Clause License   https://opensource.org/license/bsd-3-clause/

package main

// package main provides a simple landing page for an opentsg session

import (
	"embed"
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/phsym/console-slog"
)

var Port=8080

//go:embed releases.yaml www templates
var embedFs embed.FS

	var Logger *slog.Logger
func main() {
	initTemplates(embedFs)

	r := chi.NewRouter()

		// use the default logger 
		r.Use(middleware.Logger)
	// recover from panics and set return status
	r.Use(middleware.Recoverer)

	//set up routes
	r.Get("/", RouteLanding)

	// simple embedded file server for logs & static images, pages etc.
	embedFileServer(r, embedFs, "/r/", "www")
	listenAddr := fmt.Sprintf("%s:%d", "", Port)
	slog.Info(fmt.Sprintf("Listening on port %d", Port))

	// run the server in a thread
	http.ListenAndServe(listenAddr, r)
}

func init(){
		Logger = slog.New(
			console.NewHandler(os.Stderr,
				&console.HandlerOptions{Level: slog.LevelDebug}))
		slog.SetDefault(Logger)
}