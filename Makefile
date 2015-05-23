all:	static/index.html	build/selfdashboard
	@true

static/index.html:	Main.elm
	elm package install
	elm make Main.elm --output static/index.html

build/selfdashboard:	main.go
	gofmt -w .
	go build -o build/selfdashboard .

run:	static/index.html	build/selfdashboard
	go get github.com/ddollar/forego
	PATH=./build:${PATH} forego start
