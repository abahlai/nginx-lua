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
	
	stage('Build Nginx') {
      //Build
      sh '''
        wget http://luajit.org/download/LuaJIT-2.0.5.zip
		unzip LuaJIT-2.0.5.zip
		cd LuaJIT-2.0.5
		make && sudo make install && cd ..
		wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip
		unzip v0.3.0.zip
		wget https://github.com/openresty/lua-nginx-module/archive/v0.10.11.zip
		unzip v0.10.11.zip
		wget http://nginx.org/download/nginx-1.13.6.tar.gz
		tar -xzvf nginx-1.13.6.tar.gz
		cd nginx-1.13.6/
		export LUAJIT_LIB=/usr/local/lib
		export LUAJIT_INC=/usr/local/include/luajit-2.0
		./configure --prefix=/opt/nginx \
            --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
			--without-http_rewrite_module \
			--without-http_gzip_module \
            --add-dynamic-module="../ngx_devel_kit-0.3.0" \
            --add-dynamic-module="../lua-nginx-module-0.10.11"
		make -j2
		sudo make install
      '''
    }
	  
	stage('Build nginx image') {
	sh '''
	  docker build -t nginx-lua
	'''
	}
	
	stage('Push nginx image') {
	sh '''
	  docker tag nginx-lua nikotinik/nginx-lua
	  docker push nikotinik/nginx-lua
	'''
	}
}