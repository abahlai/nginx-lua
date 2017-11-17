FROM ubuntu:xenial
ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0
RUN apt update && apt install make gcc unzip wget -y
WORKDIR build
RUN wget http://luajit.org/download/LuaJIT-2.0.5.zip && unzip LuaJIT-2.0.5.zip
WORKDIR LuaJIT-2.0.5
RUN make && make install
WORKDIR build
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip && unzip v0.3.0.zip && \
    wget https://github.com/openresty/lua-nginx-module/archive/v0.10.11.zip && unzip v0.10.11.zip && \
    wget http://nginx.org/download/nginx-1.13.6.tar.gz && tar -xzvf nginx-1.13.6.tar.gz
WORKDIR nginx-1.13.6
RUN ./configure --prefix=/opt/nginx \
                --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
		--without-http_rewrite_module \
		--without-http_gzip_module \
                --add-dynamic-module=../ngx_devel_kit-0.3.0 \
                --add-dynamic-module=../lua-nginx-module-0.10.11
RUN make -j2 && make install
COPY index.html /opt/nginx/html
COPY nginx.conf /opt/nginx/conf
EXPOSE 80
CMD ["/opt/nginx/sbin/nginx"]
