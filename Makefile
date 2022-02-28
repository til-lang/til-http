libtil_http.so: source/app.d
	ldc2 --shared source/app.d \
		-I=til/source \
		-link-defaultlib-shared \
		-L-L${PWD}/dist -L-L${LIBTIL_PATH} -L-ltil \
		--O2 -of=dist/libtil_http.so

test:
	til/til.release test.til
