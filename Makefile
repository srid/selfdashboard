all:	static/index.html	build/selfdashboard
	@true

static/index.html:	Main.elm
	elm package install
	elm make Main.elm --output static/index.html

build/selfdashboard:	*.go
	gofmt -w .
	go build -o build/selfdashboard .

run:	static/index.html	build/selfdashboard
	go get github.com/ddollar/forego
	PATH=./build:${PATH} forego start

deploy:
	output=$(git status --porcelain) && [ -z "${output}" ] && git push -f heroku master
