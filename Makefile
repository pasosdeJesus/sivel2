
valida: valida-js valida-ruby

valida-js:
	for i in `find app/assets/javascripts/ -name "*coffee"`; do \
	coffee -o /tmp/ $$i; \
	done

valida-ruby:
	find . -name "*\.rb" -exec ruby -w -W2 -c {} ';'

erd:
	bundle exec erd
	mv erd.pdf doc/
	convert doc/erd.pdf doc/erd.png
