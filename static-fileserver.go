// Copyright ©2022-2024 Mr MXF   info@mrmxf.com
// BSD-3-Clause License   https://opensource.org/license/bsd-3-clause/

package main

import (
	"embed"
	"io/fs"
	"log/slog"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/go-chi/chi/v5"
)

func setContentType(w http.ResponseWriter, r *http.Request){
	ext := filepath.Ext(r.RequestURI)
	switch(ext){
	case ".css":
		w.Header().Set("Content-Type", "text/css")
	case ".js":
		w.Header().Set("Content-Type", "text/javascript")
	case ".html":
		w.Header().Set("Content-Type", "text/html")
	case ".svg":
		w.Header().Set("Content-Type", "image/svg+xml")
	case ".png":
		w.Header().Set("Content-Type", "image/png")
	case ".ico":
		w.Header().Set("Content-Type", "image/x-icon")
	case ".json":
		w.Header().Set("Content-Type", "application/json")
	case ".txt":
		w.Header().Set("Content-Type", "text/plain")
	case ".xml":
		w.Header().Set("Content-Type", "application/xml")
	case ".woff":
		w.Header().Set("Content-Type", "font/woff")
	case ".woff2":
		w.Header().Set("Content-Type", "font/woff2")
	case ".ttf":
		w.Header().Set("Content-Type", "font/ttf")
	case ".otf":
		w.Header().Set("Content-Type", "font/otf")
	case ".eot":
		w.Header().Set("Content-Type", "application/vnd.ms-fontobject")
	case ".wasm":
		w.Header().Set("Content-Type", "application/wasm")
	default:
		w.Header().Set("Content-Type", "text/plain")
	}
}

// embedFileServer conveniently sets up a http.embedFileServer handler to serve
// static files from a http.FileSystem.
func embedFileServer(r chi.Router, eFs embed.FS, route string, eFsRootPath string) {
	if strings.ContainsAny(route, "{}*") {
		slog.Error("embedFileServer mount route does not permit any URL parameters.")
		return
	}

	fSys, err := fs.Sub(eFs, eFsRootPath)
	if err != nil {
		slog.Error("embedFileServer cannot find embedded files")
		return
	}

	// check for trailing slash
	if route != "/" && route[len(route)-1] != '/' {
		r.Get(route, http.RedirectHandler(route+"/", http.StatusMovedPermanently).ServeHTTP)
		route += "/"
	}
	route += "*"

	r.Get(route,
		func(w http.ResponseWriter, r *http.Request) {
			setContentType(w, r)
			rCtx := chi.RouteContext(r.Context())
			pathPrefix := strings.TrimSuffix(rCtx.RoutePattern(), "/*")
			fs := http.StripPrefix(pathPrefix, http.FileServer(http.FS(fSys)))
			fs.ServeHTTP(w, r)
		})
}
