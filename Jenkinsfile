node {
    def GIT_REPO_URL
    def GIT_BRANCH
 
    stage ('Initialize') {
      // Git repo
      GIT_REPO_URL = 'https://github.com/nikotinik/nginx-lua'
      GIT_BRANCH = 'master'
    }
	
	stage('Git Checkout') {
      git url: "${GIT_REPO_URL}" , branch: "${GIT_BRANCH}"
    }
	
	stage('Build') {
      //Build
      sh '''
	    wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.gz && tar -zxf pcre-8.41.tar.gz && cd pcre-8.41 && \
		./configure && make && sudo make install && cd ..
		wget http://zlib.net/zlib-1.2.11.tar.gz && tar -zxf zlib-1.2.11.tar.gz && cd zlib-1.2.11 && \
		./configure && make && sudo make install && cd ..
		wget http://www.openssl.org/source/openssl-1.0.2k.tar.gz && tar -zxf openssl-1.0.2k.tar.gz && cd openssl-1.0.2k && \
		./config && make && sudo make install && cd ..
        	wget http://luajit.org/download/LuaJIT-2.0.5.zip && unzip LuaJIT-2.0.5.zip && cd LuaJIT-2.0.5 && make && sudo make install && cd ..
		wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip && unzip v0.3.0.zip
		wget https://github.com/openresty/lua-nginx-module/archive/v0.10.11.zip && unzip v0.10.11.zip
		wget http://nginx.org/download/nginx-1.13.6.tar.gz && tar -xzvf nginx-1.13.6.tar.gz && cd nginx-1.13.6
		export LUAJIT_LIB=/usr/local/lib
		export LUAJIT_INC=/usr/local/include/luajit-2.0
		./configure ./configure --sbin-path=/usr/local/nginx/nginx \
					--conf-path=/usr/local/nginx/nginx.conf \
					--pid-path=/usr/local/nginx/nginx.pid \
					--with-pcre=../pcre-8.41 \
					--with-zlib=../zlib-1.2.11 \
					--with-http_ssl_module \
					--with-stream \
					--with-mail=dynamic \
					--with-ld-opt="-Wl,-rpath,/usr/local/lib" \
					--add-dynamic-module=../ngx_devel_kit-0.3.0 \
					--add-dynamic-module=../lua-nginx-module-0.10.11
		make -j2
		sudo make install && cd ..
		rm -rf *.tar.rg && rm -rf *.zip
      '''
    }
	  
	stage('Dockerize') {
	sh '''
	  docker build -t nginx-lua
	  docker tag nginx-lua nikotinik/nginx-lua
	  docker push nikotinik/nginx-lua
	'''
	}
	
	stage('Deploy') {
	sh '''
	  docker-machine create --driver amazonec2 --amazonec2-open-port 80 --amazonec2-region eu-central-1 aws-nginx
	  docker-machine ssh aws-nginx
	  docker run -d -p 80:80 --name nginx-lua nikotinik/nginx-lua
	'''
	}
}
