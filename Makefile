
all: sintaxis-js sintaxis-ruby bundler-audit brakeman sintaxis-erb rubocop

sintaxis-js:
	for i in `find app/assets/javascripts/ -name "*js"`; do \
		node -c $$i; \
	done # Falta es6

sintaxis-ruby:
	find . -name "*\.rb" -exec ruby -w -W2 -c {} ';'

instala-gemas:
	grep "([0-9]" Gemfile.lock  | sed -e "s/^ */doas gem install /g;s/ (/ -v /g;s/)//g" > /tmp/i.sh
	doas chmod +x /tmp/i.sh
	doas /tmp/i.sh

erd:  # Antes de esto instalar graphviz con doas pkg_add graphviz
	(cd test/dummy; \
	bundle exec erd)
	mv test/dummy/erd.pdf doc/
	pdftoppm doc/erd.pdf doc/erd
	convert doc/erd-1.ppm doc/erd.png
	rm doc/erd-1.ppm

doc/dependencias.png: doc/dependencias.dot
	dot -Tpng doc/dependencias.dot  > doc/dependencias.png


bundler-audit:
	bin/bundler-audit

brakeman:
	bin/brakeman

rubocop:
	bin/rubocop

c_brakeman:
	bin/brakeman -I

c_rubocop:
	bin/rubocop -a

yard:
	yard

sintaxis-erb:
	rake sintaxis:erb
