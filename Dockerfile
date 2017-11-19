FROM ubuntu:xenial

ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0
ENV PCRE_PKG pcre-8.41
ENV ZLIB_PKG zlib-1.2.11
ENV OPENSSL_PKG openssl-1.0.2k
ENV LUAJIT_PKG LuaJIT-2.0.5
ENV NGINX_PKG nginx-1.13.6

RUN apt update && apt install make gcc unzip wget build-essential -y
WORKDIR /build
RUN wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_PKG}.tar.gz && tar -zxf ${PCRE_PKG}.tar.gz
WORKDIR ${PCRE_PKG}
RUN ./configure && make && make install
WORKDIR /build
RUN wget http://zlib.net/${ZLIB_PKG}.tar.gz && tar -zxf ${ZLIB_PKG}.tar.gz
WORKDIR ${ZLIB_PKG}
RUN ./configure && make && make install
WORKDIR /build
RUN wget http://www.openssl.org/source/${OPENSSL_PKG}.tar.gz && tar -zxf ${OPENSSL_PKG}.tar.gz
WORKDIR ${OPENSSL_PKG}
RUN ./config --prefix=/usr && make && make install
WORKDIR /build
RUN wget http://luajit.org/download/${LUAJIT_PKG}.zip && unzip ${LUAJIT_PKG}.zip
WORKDIR ${LUAJIT_PKG}
RUN make && make install
WORKDIR /build
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip && unzip v0.3.0.zip && \
    wget https://github.com/openresty/lua-nginx-module/archive/v0.10.11.zip && unzip v0.10.11.zip && \
    wget http://nginx.org/download/${NGINX_PKG}.tar.gz && tar -xzvf ${NGINX_PKG}.tar.gz

WORKDIR ${NGINX_PKG}
RUN ./configure --sbin-path=/usr/local/nginx/nginx \
		--conf-path=/usr/local/nginx/nginx.conf \
		--pid-path=/usr/local/nginx/nginx.pid \
		--with-pcre=../${PCRE_PKG} \
		--with-zlib=../${ZLIB_PKG} \
		--with-http_ssl_module \
		--with-stream \
		--with-mail=dynamic \
                --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
                --add-dynamic-module=../ngx_devel_kit-0.3.0 \
                --add-dynamic-module=../lua-nginx-module-0.10.11
RUN make -j2 && make install
WORKDIR /build
RUN rm -rf *.tar.gz && rm -rf *.zip
COPY index.html /usr/local/nginx/html
COPY nginx.conf /usr/local/nginx/conf
RUN useradd -r nginx
EXPOSE 80
CMD ["/usr/local/nginx/nginx","-g","'daemon on; master_process on;'"]
